# ZBCPARAM — Constant Parameter

| Item | Value |
|------|-------|
| Package | **`ZBCPARAM`** (superpackage `ZCUSTOM_DEVELOPMENT`) |
| Software component | `ZCUSTOM_DEVELOPMENT` |
| Platform | SAP S/4HANA Cloud **Public Edition** · ABAP for Cloud Development |
| หน้าที่ | เก็บค่า constant ของทุก RICEFW ไว้ใน table กลาง `ZTBC_PARAM` แทนการ hardcode · อ่านผ่าน `ZCL_PARAM` |
| ผู้ใช้ปัจจุบัน | **Custom Logic** (key user) บน tenant · **ZIME001** · **`ZCL_UTILITY`** — รายละเอียดใน `docs/01_objects.md` |
| Repo sync | abapGit (tenant ⇄ GitHub ⇄ local) |

> `ZCL_PARAM` / `ZCX_PARAM` release **C1 + Use in Key User Apps** และมี Custom Logic เรียกใช้อยู่จริง
> → แก้ได้เฉพาะแบบ compatible ดู `CLAUDE.md`

## สิ่งที่อยู่ในนี้

| กลุ่ม | Object | หน้าที่ |
|---|---|---|
| Table | `ZTBC_PARAM` | constant parameter · key = company code / module / app ID / param name / additional param / sequence / end date |
| Utility | `ZCL_PARAM` | อ่านค่าจาก `ZTBC_PARAM` — pre-select เข้า buffer ตอนสร้าง instance แล้วอ่านเป็นค่าเดี่ยวหรือ range |
| | `ZCX_PARAM` | exception ของ `ZCL_PARAM` · reason อยู่ใน `GV_REASON` |
| | `ZCL_PARAM_DEMO` | ตัวอย่างการเรียกใช้ 9 แบบ (กด F9 ใน ADT) · ไม่ release |
| Maintenance app | `ZI_CONSTANTPARAMETER(_S)` · `ZUI_CONSTANTPARAMETER_O4` · `ZCONSTANTPARAMETER` (SMBC) | Fiori **Maintain Constant Parameter** สำหรับ maintain ข้อมูลใน `ZTBC_PARAM` (RAP business configuration) |

รายการครบทุกตัวอยู่ใน `docs/01_objects.md`

## วิธีใช้แบบย่อ

```abap
DATA lv_doc_type TYPE c LENGTH 4.
DATA lr_doc_type TYPE RANGE OF c LENGTH 4.

" สร้าง instance ผ่าน factory เท่านั้น (CREATE PRIVATE)
" ส่ง company code / module = โหลดเฉพาะ scope นั้นเข้า buffer
DATA(lo_param) = zcl_param=>create_instance( iv_company_code = '1000'
                                             iv_module_id    = 'SD' ).

TRY.
    " ค่าเดี่ยว -> แปลงเป็น type ของตัวแปรที่ส่งมารับให้เอง
    lo_param->get_value( EXPORTING iv_app_id     = 'ZSDE002'
                                   iv_param_name = 'DOCTY'
                         IMPORTING ev_value      = lv_doc_type ).

    " range -> ส่ง RANGE OF ของตัวเองมารับ แล้วใช้ใน WHERE ... IN ได้เลย
    lo_param->get_range( EXPORTING iv_app_id     = 'ZSDE002'
                                   iv_param_name = 'DOCTY'
                         IMPORTING et_range      = lr_doc_type ).

  CATCH zcx_param INTO DATA(lx_param).
    " lx_param->gv_reason = NOT_FOUND / INVALID_PARAM / INVALID_TYPE
ENDTRY.
```

ตัวอย่างครบทุกแบบดูใน `src/zcl_param_demo.clas.abap`

## พฤติกรรมที่ต้องรู้

| เรื่อง | พฤติกรรม |
|---|---|
| parameter optional | **ไม่ส่ง = ไม่นำไปกรอง** (ไม่ใช่กรองด้วยค่าว่าง) · อยากได้เฉพาะค่าว่างให้ส่ง `space` มาเอง |
| scope | ระบุตอน `create_instance( )` ก็ได้ ระบุตอนอ่านก็ได้ · ระบุตอนสร้าง = buffer เล็กลง |
| validity | โหลดเฉพาะ record ที่ `START_DATE <= วันนี้ <= END_DATE` · วันนี้ = วันที่ **UTC** ในทางปฏิบัติ (ดู `CLAUDE.md`) |
| ลำดับ | เรียงตาม primary key · `get_value( )` ได้ record แรก = `SEQUENCE` ต่ำสุด · ระบุ `iv_sequence` เพื่อเลือกตัวที่ต้องการ |
| range | `PARAM_SIGN` / `PARAM_OPTION` ต้อง maintain ครบ ไม่งั้น raise `INVALID_PARAM` (ไม่เดาค่าให้) |
| invisible char | key field ใน buffer ถูกล้าง NBSP / zero-width / BOM ด้วย `zcl_utility=>remove_invisible_char( )` ตอนโหลด |
| exception | `NOT_FOUND` ไม่พบ record · `INVALID_PARAM` range ไม่มี sign/option · `INVALID_TYPE` แปลงค่าเข้า type ของ caller ไม่ได้ (ต้นเหตุอยู่ใน `previous`) |
| อ่าน buffer ตรง | `lo_param->gt_param` เป็น `READ-ONLY` อ่านเองได้ · ไม่เจอไม่ raise |

## Repository layout

```
fplus-zbcparam/
├── README.md
├── CLAUDE.md                 # กฎเฉพาะ package นี้
├── docs/01_objects.md        # object list + consumer + status
├── .abapgit.xml              # tenant serialize เอง ห้ามแก้มือ (FULL · /src/)
└── src/                      # abapGit sync
```

## Sync workflow

ABAP object ผู้ใช้สร้าง/แก้ใน ADT แล้ว push ผ่าน abapGit · เอกสาร Claude commit + push
