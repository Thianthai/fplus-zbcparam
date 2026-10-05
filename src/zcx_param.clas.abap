"! Exception ที่ ZCL_PARAM raise เมื่ออ่านค่าจาก ZTBC_PARAM ไม่ได้
"! สาเหตุดูได้จาก GV_REASON ค่าที่เป็นไปได้อยู่ใน GC_REASON
CLASS zcx_param DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CONSTANTS:
      "! สาเหตุของ exception เก็บไว้ใน GV_REASON
      BEGIN OF gc_reason,
        "! ไม่พบ record ตามเงื่อนไขที่ระบุ
        not_found     TYPE string VALUE 'NOT_FOUND',

        "! record ที่จะใช้เป็น range ไม่ได้ระบุ PARAM_SIGN / PARAM_OPTION
        invalid_param TYPE string VALUE 'INVALID_PARAM',

        "! แปลง LOW_VALUE เป็น type ของตัวแปรที่ caller ส่งมาไม่ได้
        invalid_type  TYPE string VALUE 'INVALID_TYPE',
      END OF gc_reason.

    "! สาเหตุ — ค่าจาก GC_REASON
    DATA gv_reason     TYPE string                READ-ONLY.

    "! key ของ record ที่มีปัญหา
    DATA gv_app_id     TYPE ztbc_param-app_id     READ-ONLY.
    DATA gv_param_name TYPE ztbc_param-param_name READ-ONLY.
    DATA gv_param_ext  TYPE ztbc_param-param_ext  READ-ONLY.
    DATA gv_sequence   TYPE ztbc_param-sequence   READ-ONLY.

    "! สร้าง exception พร้อม key ของ record ที่มีปัญหา
    "! @parameter textid        | Text ID มาตรฐานของ exception class
    "! @parameter previous      | exception ต้นเหตุ เช่น conversion error
    "! @parameter iv_reason     | สาเหตุ ค่าจาก GC_REASON
    "! @parameter iv_app_id     | Application ID ของ record ที่มีปัญหา
    "! @parameter iv_param_name | Parameter name ของ record ที่มีปัญหา
    "! @parameter iv_param_ext  | Additional parameter ของ record ที่มีปัญหา
    "! @parameter iv_sequence   | Sequence no. ของ record ที่มีปัญหา
    METHODS constructor
      IMPORTING textid        LIKE textid                OPTIONAL
                previous      LIKE previous              OPTIONAL
                iv_reason     TYPE string                OPTIONAL
                iv_app_id     TYPE ztbc_param-app_id     OPTIONAL
                iv_param_name TYPE ztbc_param-param_name OPTIONAL
                iv_param_ext  TYPE ztbc_param-param_ext  OPTIONAL
                iv_sequence   TYPE ztbc_param-sequence   OPTIONAL.

    METHODS if_message~get_text REDEFINITION.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCX_PARAM IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.

    super->constructor( textid   = textid
                        previous = previous ).

    gv_reason     = iv_reason.
    gv_app_id     = iv_app_id.
    gv_param_name = iv_param_name.
    gv_param_ext  = iv_param_ext.
    gv_sequence   = iv_sequence.

  ENDMETHOD.


  METHOD if_message~get_text.

    result = COND #(
      WHEN gv_reason = gc_reason-invalid_param
        THEN |Invalid parameter in ZTBC_PARAM (PARAM_SIGN / PARAM_OPTION not maintained)|
      WHEN gv_reason = gc_reason-invalid_type
        THEN |Invalid parameter type|
      WHEN gv_reason = gc_reason-not_found
        THEN |No constant parameter found|
      ELSE |Constant parameter error| ).

    result = |{ result }: APP_ID={ gv_app_id }, PARAM_NAME={ gv_param_name }|.

    IF gv_param_ext IS NOT INITIAL.
      result = |{ result }, PARAM_EXT={ gv_param_ext }|.
    ENDIF.

    IF gv_reason = gc_reason-invalid_param.
      result = |{ result }, SEQUENCE={ gv_sequence }|.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
