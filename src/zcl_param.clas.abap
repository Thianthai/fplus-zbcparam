"! Utility class สำหรับอ่านค่า constant จาก table ZTBC_PARAM
CLASS zcl_param DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE .

  PUBLIC SECTION.

    TYPES:
      "! 1 บรรทัดของ range table
      "! ชื่อ component ตรงกับ RANGE OF / SELECT-OPTIONS มาตรฐาน
      BEGIN OF ty_range_value,
        sign   TYPE ddsign,
        option TYPE ddoption,
        low    TYPE ztbc_param-low_value,
        high   TYPE ztbc_param-high_value,
      END OF ty_range_value.

    "! record ของ ZTBC_PARAM ทั้งแถว
    TYPES tt_param       TYPE STANDARD TABLE OF ztbc_param WITH EMPTY KEY.
    "! range table สำเร็จรูป
    "! ใช้รับค่าจาก GET_RANGE ได้เลย ถ้าไม่อยากประกาศ RANGE OF เอง
    TYPES tt_range_value TYPE STANDARD TABLE OF ty_range_value WITH EMPTY KEY.

    "! record ที่ pre-select ไว้ตอนสร้าง object — อ่านได้จากภายนอก แก้ไม่ได้
    DATA gt_param TYPE tt_param READ-ONLY.

    "! สร้าง instance พร้อม pre-select record จาก ZTBC_PARAM เก็บไว้ใน buffer
    "! @parameter iv_company_code | Company code (ไม่ส่ง = ไม่นำไปกรอง)
    "! @parameter iv_module_id    | Module (ไม่ส่ง = ไม่นำไปกรอง)
    "! @parameter ro_instance     | Instance ของ ZCL_PARAM
    CLASS-METHODS create_instance
      IMPORTING iv_company_code    TYPE ztbc_param-company_code OPTIONAL
                iv_module_id       TYPE ztbc_param-module_id    OPTIONAL
      RETURNING VALUE(ro_instance) TYPE REF TO zcl_param.

    "! ลบ invisible character (NBSP, zero-width space, BOM, ideographic space)
    "! ที่อาจติดมาจากการ copy-paste จาก Excel / Word / web
    CLASS-METHODS sanitize
      IMPORTING iv_text        TYPE clike
      RETURNING VALUE(rv_text) TYPE string.

    "! อ่านค่าเดี่ยวจาก buffer
    "! ได้ LOW_VALUE ของ record แรกที่ตรงเงื่อนไข ซึ่งคือ SEQUENCE ต่ำสุด
    "! @parameter iv_company_code | Company code (ไม่ส่ง = ไม่นำไปกรอง)
    "! @parameter iv_module_id    | Module (ไม่ส่ง = ไม่นำไปกรอง)
    "! @parameter iv_app_id       | Application ID
    "! @parameter iv_param_name   | Parameter name
    "! @parameter iv_param_ext    | Additional parameter (ไม่ส่ง = ไม่นำไปกรอง)
    "! @parameter iv_sequence     | Sequence no. (ไม่ส่ง = ไม่นำไปกรอง)
    "! @parameter ev_value        | ตัวแปรของ caller ประกาศ type อะไรก็ได้
    "!                              ระบบแปลง LOW_VALUE เป็น type นั้นให้ตอน assign
    "! @raising   zcx_param       | NOT_FOUND -> ไม่พบ record ตามเงื่อนไข
    "!                              INVALID_TYPE -> แปลง LOW_VALUE เป็น type ของ EV_VALUE ไม่ได้
    METHODS get_value
      IMPORTING iv_company_code TYPE ztbc_param-company_code OPTIONAL
                iv_module_id    TYPE ztbc_param-module_id    OPTIONAL
                iv_app_id       TYPE ztbc_param-app_id
                iv_param_name   TYPE ztbc_param-param_name
                iv_param_ext    TYPE ztbc_param-param_ext    OPTIONAL
                iv_sequence     TYPE ztbc_param-sequence     OPTIONAL
      EXPORTING ev_value        TYPE any
      RAISING   zcx_param.

    "! อ่านค่าเป็น range table จาก buffer เรียงตาม SEQUENCE
    "! SIGN / OPTION มาจาก PARAM_SIGN / PARAM_OPTION
    "! LOW / HIGH มาจาก LOW_VALUE / HIGH_VALUE
    "! @parameter iv_company_code | Company code (ไม่ส่ง = ไม่นำไปกรอง)
    "! @parameter iv_module_id    | Module (ไม่ส่ง = ไม่นำไปกรอง)
    "! @parameter iv_app_id       | Application ID
    "! @parameter iv_param_name   | Parameter name
    "! @parameter iv_param_ext    | Additional parameter (ไม่ส่ง = ไม่นำไปกรอง)
    "! @parameter iv_sequence     | Sequence no. (ไม่ส่ง = ไม่นำไปกรอง)
    "! @parameter et_range        | range table ของ caller
    "!                              จะเป็น RANGE OF ... หรือ TT_RANGE_VALUE ก็ได้
    "! @raising   zcx_param       | NOT_FOUND -> ไม่พบ record ตามเงื่อนไข
    "!                              INVALID_PARAM -> มี record ที่ไม่ได้ระบุ PARAM_SIGN / PARAM_OPTION
    METHODS get_range
      IMPORTING iv_company_code TYPE ztbc_param-company_code OPTIONAL
                iv_module_id    TYPE ztbc_param-module_id    OPTIONAL
                iv_app_id       TYPE ztbc_param-app_id
                iv_param_name   TYPE ztbc_param-param_name
                iv_param_ext    TYPE ztbc_param-param_ext    OPTIONAL
                iv_sequence     TYPE ztbc_param-sequence     OPTIONAL
      EXPORTING et_range        TYPE STANDARD TABLE
      RAISING   zcx_param.

  PROTECTED SECTION.
  PRIVATE SECTION.

    "! Pre-select record จาก ZTBC_PARAM เก็บไว้ใน buffer
    "! เรียกผ่าน CREATE_INSTANCE เท่านั้น (CREATE PRIVATE)
    METHODS constructor
      IMPORTING iv_company_code TYPE ztbc_param-company_code OPTIONAL
                iv_module_id    TYPE ztbc_param-module_id    OPTIONAL.

    "! กรอง GT_PARAM ตามเงื่อนไขที่ส่งมา เรียงตามลำดับเดิม (primary key)
    "! IV_HAS_* บอกว่า parameter ตัวนั้นถูกส่งมาหรือไม่ — ไม่ส่ง = ไม่นำไปกรอง
    METHODS filter_param
      IMPORTING iv_app_id           TYPE ztbc_param-app_id
                iv_param_name       TYPE ztbc_param-param_name
                iv_company_code     TYPE ztbc_param-company_code
                iv_has_company_code TYPE abap_bool
                iv_module_id        TYPE ztbc_param-module_id
                iv_has_module_id    TYPE abap_bool
                iv_param_ext        TYPE ztbc_param-param_ext
                iv_has_param_ext    TYPE abap_bool
                iv_sequence         TYPE ztbc_param-sequence
                iv_has_sequence     TYPE abap_bool
      RETURNING VALUE(rt_param)     TYPE tt_param.

ENDCLASS.



CLASS ZCL_PARAM IMPLEMENTATION.


  METHOD create_instance.

    " ต้องแยกเคสตาม IS SUPPLIED
    " ถ้าส่งต่อทุกตัวเสมอ constructor จะมองว่า ส่งมาแล้วแต่ค่าว่าง แล้วเอาค่าว่างไปใส่ range ทำให้ผลลัพธ์ไม่ถูกต้อง
    IF iv_company_code IS SUPPLIED AND iv_module_id IS SUPPLIED.
      ro_instance = NEW zcl_param( iv_company_code = iv_company_code
                                   iv_module_id    = iv_module_id ).

    ELSEIF iv_company_code IS SUPPLIED.
      ro_instance = NEW zcl_param( iv_company_code = iv_company_code ).

    ELSEIF iv_module_id IS SUPPLIED.
      ro_instance = NEW zcl_param( iv_module_id = iv_module_id ).

    ELSE.
      ro_instance = NEW zcl_param( ).

    ENDIF.

  ENDMETHOD.


  METHOD constructor.

    DATA lr_company_code TYPE RANGE OF ztbc_param-company_code.
    DATA lr_module_id    TYPE RANGE OF ztbc_param-module_id.
    DATA lv_current_date TYPE d.
    DATA lv_current_time TYPE t.

    " ส่งมาเฉพาะตัวไหน ก็ใส่ range เฉพาะตัวนั้น
    " range ว่าง = ไม่ถูกนำไปกรอง
    IF iv_company_code IS SUPPLIED.
      lr_company_code = VALUE #( ( sign = 'I' option = 'EQ' low = iv_company_code ) ).
    ENDIF.

    IF iv_module_id IS SUPPLIED.
      lr_module_id = VALUE #( ( sign = 'I' option = 'EQ' low = iv_module_id ) ).
    ENDIF.

    " system เป็น UTC -> แปลงเป็นวันที่ตาม time zone ของ user ก่อน กันเพี้ยนข้ามวัน
    TRY.
        DATA(lv_time_zone) = cl_abap_context_info=>get_user_time_zone( ).

        CONVERT UTCLONG utclong_current( )
                INTO DATE lv_current_date
                     TIME lv_current_time
                TIME ZONE lv_time_zone.

      CATCH cx_abap_context_info_error.
        " หา time zone ของ user ไม่ได้ -> ใช้วันที่ของระบบ (UTC) แทน
        lv_current_date = cl_abap_context_info=>get_system_date( ).
    ENDTRY.

    " เอาเฉพาะ record ที่ยัง valid ณ วันที่ปัจจุบัน
    SELECT *
      FROM ztbc_param
      WHERE company_code IN @lr_company_code
        AND module_id    IN @lr_module_id
        AND end_date     GE @lv_current_date
        AND start_date   LE @lv_current_date
      ORDER BY PRIMARY KEY
      INTO TABLE @gt_param.

    " normalize buffer หนึ่งครั้ง -> LOOP WHERE / table expression ข้างล่างใช้ได้ตรง ๆ
    LOOP AT gt_param ASSIGNING FIELD-SYMBOL(<ls_param>).
      <ls_param>-company_code = sanitize( <ls_param>-company_code ).
      <ls_param>-module_id    = sanitize( <ls_param>-module_id ).
      <ls_param>-app_id       = sanitize( <ls_param>-app_id ).
      <ls_param>-param_name   = sanitize( <ls_param>-param_name ).
      <ls_param>-param_ext    = sanitize( <ls_param>-param_ext ).
    ENDLOOP.

  ENDMETHOD.


  METHOD filter_param.

    LOOP AT gt_param INTO DATA(ls_param)
      WHERE app_id     = iv_app_id
        AND param_name = iv_param_name.

      IF iv_has_company_code = abap_true AND ls_param-company_code <> iv_company_code.
        CONTINUE.
      ENDIF.

      IF iv_has_module_id = abap_true AND ls_param-module_id <> iv_module_id.
        CONTINUE.
      ENDIF.

      IF iv_has_param_ext = abap_true AND ls_param-param_ext <> iv_param_ext.
        CONTINUE.
      ENDIF.

      IF iv_has_sequence = abap_true AND ls_param-sequence <> iv_sequence.
        CONTINUE.
      ENDIF.

      APPEND ls_param TO rt_param.

    ENDLOOP.

  ENDMETHOD.


  METHOD get_value.

    DATA(lt_param) = filter_param(
      iv_app_id           = iv_app_id
      iv_param_name       = iv_param_name
      iv_company_code     = iv_company_code
      iv_has_company_code = xsdbool( iv_company_code IS SUPPLIED )
      iv_module_id        = iv_module_id
      iv_has_module_id    = xsdbool( iv_module_id IS SUPPLIED )
      iv_param_ext        = iv_param_ext
      iv_has_param_ext    = xsdbool( iv_param_ext IS SUPPLIED )
      iv_sequence         = iv_sequence
      iv_has_sequence     = xsdbool( iv_sequence IS SUPPLIED ) ).

    IF lt_param IS INITIAL.
      RAISE EXCEPTION TYPE zcx_param
        EXPORTING iv_reason     = zcx_param=>gc_reason-not_found
                  iv_app_id     = iv_app_id
                  iv_param_name = iv_param_name
                  iv_param_ext  = iv_param_ext
                  iv_sequence   = iv_sequence.
    ENDIF.

    TRY.
        " GT_PARAM เรียงตาม primary key อยู่แล้ว -> record แรกที่ตรง คือ SEQUENCE ต่ำสุด
        ev_value = lt_param[ 1 ]-low_value.

      CATCH cx_sy_conversion_error INTO DATA(lx_conversion).
        RAISE EXCEPTION TYPE zcx_param
          EXPORTING previous      = lx_conversion
                    iv_reason     = zcx_param=>gc_reason-invalid_type
                    iv_app_id     = iv_app_id
                    iv_param_name = iv_param_name
                    iv_param_ext  = iv_param_ext
                    iv_sequence   = iv_sequence.
    ENDTRY.

  ENDMETHOD.


  METHOD get_range.

    FIELD-SYMBOLS <ls_line> TYPE any.

    DATA(lt_param) = filter_param(
      iv_app_id           = iv_app_id
      iv_param_name       = iv_param_name
      iv_company_code     = iv_company_code
      iv_has_company_code = xsdbool( iv_company_code IS SUPPLIED )
      iv_module_id        = iv_module_id
      iv_has_module_id    = xsdbool( iv_module_id IS SUPPLIED )
      iv_param_ext        = iv_param_ext
      iv_has_param_ext    = xsdbool( iv_param_ext IS SUPPLIED )
      iv_sequence         = iv_sequence
      iv_has_sequence     = xsdbool( iv_sequence IS SUPPLIED )  ).

    IF lt_param IS INITIAL.
      RAISE EXCEPTION TYPE zcx_param
        EXPORTING iv_reason     = zcx_param=>gc_reason-not_found
                  iv_app_id     = iv_app_id
                  iv_param_name = iv_param_name
                  iv_param_ext  = iv_param_ext.
    ENDIF.

    LOOP AT lt_param INTO DATA(ls_param).

      " maintain ไม่ครบ = config ผิด ต้องรู้ว่า record ไหน
      IF ls_param-param_sign IS INITIAL OR ls_param-param_option IS INITIAL.
        RAISE EXCEPTION TYPE zcx_param
          EXPORTING iv_reason     = zcx_param=>gc_reason-invalid_param
                    iv_app_id     = ls_param-app_id
                    iv_param_name = ls_param-param_name
                    iv_param_ext  = ls_param-param_ext
                    iv_sequence   = ls_param-sequence.
      ENDIF.

      DATA(ls_range_value) = VALUE ty_range_value( sign   = ls_param-param_sign
                                                   option = ls_param-param_option
                                                   low    = ls_param-low_value
                                                   high   = ls_param-high_value ).

      " map ตามชื่อ component -> caller ใช้ RANGE OF อะไรก็ได้
      APPEND INITIAL LINE TO et_range ASSIGNING <ls_line>.
      MOVE-CORRESPONDING ls_range_value TO <ls_line>.

    ENDLOOP.

  ENDMETHOD.


  METHOD sanitize.

    rv_text = iv_text.

    " U+00A0 NBSP · U+200B-200D zero-width · U+FEFF BOM · U+3000 ideographic space
    REPLACE ALL OCCURRENCES OF PCRE `[\x{00A0}\x{200B}-\x{200D}\x{FEFF}\x{3000}]`
    IN rv_text WITH ` `.

    rv_text = condense( rv_text ).

  ENDMETHOD.
ENDCLASS.
