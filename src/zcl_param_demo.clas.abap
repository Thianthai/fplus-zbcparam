"! Demo: How to use ZCL_PARAM
"! ตัวอย่างการเรียกใช้ ZCL_PARAM จากภายนอก class
"! กด F9 ใน ADT เพื่อรันแล้วดูผลใน console
"! อ่านข้อมูลจริงจาก ZTBC_PARAM ต้อง maintain parameter ที่ใช้ใน sample ไว้ก่อน
CLASS zcl_param_demo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_param_demo IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    " type ฝั่ง caller
    " ใช้แสดงว่า ZCL_PARAM แปลงค่าให้เป็น type ที่ caller ประกาศเองได้
    TYPES ty_gl_account    TYPE c LENGTH 10.
    TYPES ty_doc_type      TYPE c LENGTH 4.
    TYPES ty_movement_type TYPE c LENGTH 3.
    TYPES ty_material_no   TYPE c LENGTH 40.

    DATA lcx_param TYPE REF TO zcx_param.

    " ----------------------------------------------------------------------------------------------------
    " Sample 1 : Get Value แบบที่ 1
    " สร้าง instance โดยไม่ระบุ scope -> โหลดทุก record
    " แล้วค่อยระบุ company code / module ตอนอ่าน
    " ----------------------------------------------------------------------------------------------------
    DATA lv_value_1 TYPE ty_gl_account.

    out->write( |Sample 1 : Get Value แบบที่ 1| ).

    DATA(lo_param_1) = zcl_param=>create_instance( ).

    TRY.
        lo_param_1->get_value( EXPORTING iv_company_code = '1000'
                                         iv_module_id    = 'FI'
                                         iv_app_id       = 'ZFIR001'
                                         iv_param_name   = 'GLACC'
                               IMPORTING ev_value        = lv_value_1 ).

        out->write( |Result 1 : { lv_value_1 }| ).

      CATCH zcx_param INTO lcx_param.
        out->write( |ERROR ({ lcx_param->gv_reason }): { lcx_param->get_text( ) }| ).
    ENDTRY.

    out->write( | | ).

    " ----------------------------------------------------------------------------------------------------
    " Sample 2 : Get Value แบบที่ 2
    " ระบุ scope ตอนสร้าง instance -> โหลดเฉพาะ record ของ scope นั้น
    " ตอนอ่านไม่ต้องส่ง company code / module ซ้ำ
    " ----------------------------------------------------------------------------------------------------
    DATA lv_value_2 TYPE ty_gl_account.

    out->write( |Sample 2 : Get Value แบบที่ 2| ).

    DATA(lo_param_2) = zcl_param=>create_instance( iv_company_code = '1000'
                                                   iv_module_id    = 'FI' ).

    TRY.
        lo_param_2->get_value( EXPORTING iv_app_id     = 'ZFIR001'
                                         iv_param_name = 'GLACC'
                               IMPORTING ev_value      = lv_value_2 ).

        out->write( |Result 2 : { lv_value_2 }| ).

      CATCH zcx_param INTO lcx_param.
        out->write( |ERROR ({ lcx_param->gv_reason }): { lcx_param->get_text( ) }| ).
    ENDTRY.

    out->write( | | ).

    " ----------------------------------------------------------------------------------------------------
    " Sample 3 : Get Range แบบที่ 1
    " ใช้ RANGE OF ของ caller เอง -> เอาไปใช้ใน SELECT ... WHERE ... IN ต่อได้เลย
    " ----------------------------------------------------------------------------------------------------
    DATA lr_doc_type TYPE RANGE OF ty_doc_type.

    out->write( |Sample 3 : Get Range แบบที่ 1| ).

    DATA(lo_param_3) = zcl_param=>create_instance( iv_company_code = '1000'
                                                   iv_module_id    = 'SD' ).

    TRY.
        lo_param_3->get_range( EXPORTING iv_app_id     = 'ZSDE002'
                                         iv_param_name = 'DOCTY'
                               IMPORTING et_range      = lr_doc_type ).

        out->write( |Result 3 :| ).
        out->write( lr_doc_type ).

      CATCH zcx_param INTO lcx_param.
        out->write( |ERROR ({ lcx_param->gv_reason }): { lcx_param->get_text( ) }| ).
    ENDTRY.

    out->write( | | ).

    " ----------------------------------------------------------------------------------------------------
    " Sample 4 : Get Range แบบที่ 2
    " ใช้ type สำเร็จรูปของ ZCL_PARAM -> ไม่ต้องประกาศ RANGE OF เอง
    " ----------------------------------------------------------------------------------------------------
    DATA lt_range TYPE zcl_param=>tt_range_value.

    out->write( |Sample 4 : Get Range แบบที่ 2| ).

    DATA(lo_param_4) = zcl_param=>create_instance( iv_company_code = '1000'
                                                   iv_module_id    = 'SD' ).

    TRY.
        lo_param_4->get_range( EXPORTING iv_app_id     = 'ZSDE002'
                                         iv_param_name = 'DOCTY'
                               IMPORTING et_range      = lt_range ).

        out->write( |Result 4 :| ).
        out->write( lt_range ).

      CATCH zcx_param INTO lcx_param.
        out->write( |ERROR ({ lcx_param->gv_reason }): { lcx_param->get_text( ) }| ).
    ENDTRY.

    out->write( | | ).

    " ----------------------------------------------------------------------------------------------------
    " Sample 5 : Free style read from buffer
    " อ่าน GT_PARAM ตรง ๆ ด้วย table expression
    " ไม่เจอ record -> ได้ค่าว่าง เพราะใช้ OPTIONAL และไม่ raise exception
    " ----------------------------------------------------------------------------------------------------
    DATA lv_value_5a TYPE ztbc_param-low_value.
    DATA lv_value_5b TYPE ztbc_param-low_value.

    DATA(lo_param_5) = zcl_param=>create_instance( ).

    lv_value_5a = VALUE #( lo_param_5->gt_param[ company_code = '1000'
                                                 module_id    = 'FI'
                                                 app_id       = 'ZFIR001'
                                                 param_name   = 'GLACC' ]-low_value OPTIONAL ).

    " SEQUENCE เป็น NUMC 3 หลัก -> ต้องส่งเป็น 3 หลักเสมอ
    lv_value_5b = VALUE #( lo_param_5->gt_param[ company_code = '1000'
                                                 module_id    = 'SD'
                                                 app_id       = 'ZSDE002'
                                                 param_name   = 'DOCTY'
                                                 sequence     = '001' ]-low_value OPTIONAL ).

    out->write( |Sample 5a : Free style read from buffer| ).
    out->write( |Result 5a : { lv_value_5a }| ).
    out->write( | | ).

    out->write( |Sample 5b : Free style read from buffer| ).
    out->write( |Result 5b : { lv_value_5b }| ).
    out->write( | | ).

    " ----------------------------------------------------------------------------------------------------
    " Sample 6 : Exception INVALID_PARAM
    " record ที่จะใช้เป็น range ไม่ได้ระบุ Sign / Option
    " ----------------------------------------------------------------------------------------------------
    DATA lr_movement_type TYPE RANGE OF ty_movement_type.

    out->write( |Sample 6 : Exception INVALID_PARAM| ).

    DATA(lo_param_6) = zcl_param=>create_instance( ).

    TRY.
        lo_param_6->get_range( EXPORTING iv_app_id     = 'ZMMR001'
                                         iv_param_name = 'MVNTY'
                               IMPORTING et_range      = lr_movement_type ).

        out->write( |ไม่เกิด exception -> record ของ parameter นี้ระบุ Sign / Option ครบแล้ว| ).

      CATCH zcx_param INTO lcx_param.
        out->write( |reason = { lcx_param->gv_reason }| ).
        out->write( lcx_param->get_text( ) ).
    ENDTRY.

    out->write( | | ).

    " ----------------------------------------------------------------------------------------------------
    " Sample 7 : Exception NOT_FOUND
    " ไม่มี parameter นี้อยู่จริงใน scope ที่ระบุ
    " ----------------------------------------------------------------------------------------------------
    DATA lv_value_7 TYPE ty_material_no.

    out->write( |Sample 7 : Exception NOT_FOUND| ).

    DATA(lo_param_7) = zcl_param=>create_instance( iv_company_code = '1000'
                                                   iv_module_id    = 'PP' ).

    TRY.
        lo_param_7->get_value( EXPORTING iv_app_id     = 'ZPPE008'
                                         iv_param_name = 'MATERIAL_NO'
                               IMPORTING ev_value      = lv_value_7 ).

        out->write( |ไม่เกิด exception -> มี parameter นี้อยู่จริง ค่าที่ได้ = { lv_value_7 }| ).

      CATCH zcx_param INTO lcx_param.
        out->write( |reason = { lcx_param->gv_reason }| ).
        out->write( lcx_param->get_text( ) ).
    ENDTRY.

    out->write( | | ).

    " ----------------------------------------------------------------------------------------------------
    " Sample 8 : Exception INVALID_TYPE
    " อ่านค่าที่เป็นตัวอักษรเข้าตัวแปร TYPE i -> แปลง type ไม่ได้
    " exception ต้นเหตุจากการแปลง type ดูได้จาก PREVIOUS
    " ----------------------------------------------------------------------------------------------------
    DATA lv_value_8 TYPE i.

    out->write( |Sample 8 : Exception INVALID_TYPE| ).

    DATA(lo_param_8) = zcl_param=>create_instance( iv_company_code = '1000'
                                                   iv_module_id    = 'SD' ).

    TRY.
        lo_param_8->get_value( EXPORTING iv_app_id     = 'ZSDE002'
                                         iv_param_name = 'DOCTY'
                               IMPORTING ev_value      = lv_value_8 ).

        out->write( |ไม่เกิด exception -> ค่าใน config แปลงเป็นตัวเลขได้ ค่าที่ได้ = { lv_value_8 }| ).

      CATCH zcx_param INTO lcx_param.
        out->write( |reason = { lcx_param->gv_reason }| ).
        out->write( lcx_param->get_text( ) ).

        IF lcx_param->previous IS BOUND.
          out->write( |previous = { lcx_param->previous->get_text( ) }| ).
        ENDIF.
    ENDTRY.

    out->write( | | ).

    " ----------------------------------------------------------------------------------------------------
    " Sample 9 : Get Value ตาม Sequence
    " parameter ที่มีหลาย record -> ระบุ IV_SEQUENCE เพื่อเลือก record ที่ต้องการ
    " ไม่ระบุ IV_SEQUENCE -> ได้ record ที่ SEQUENCE ต่ำสุด
    " ----------------------------------------------------------------------------------------------------
    DATA lv_value_9 TYPE ty_doc_type.

    out->write( |Sample 9 : Get Value ตาม Sequence| ).

    DATA(lo_param_9) = zcl_param=>create_instance( iv_company_code = '1000'
                                                   iv_module_id    = 'SD' ).

    TRY.
        lo_param_9->get_value( EXPORTING iv_app_id     = 'ZSDE002'
                                         iv_param_name = 'DOCTY'
                                         iv_sequence   = '002'
                               IMPORTING ev_value      = lv_value_9 ).

        out->write( |Result 9 : { lv_value_9 }| ).

      CATCH zcx_param INTO lcx_param.
        out->write( |ERROR ({ lcx_param->gv_reason }): { lcx_param->get_text( ) }| ).
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
