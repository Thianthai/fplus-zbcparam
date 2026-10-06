# ZBCPARAM — Object List

`⬜` ยังไม่สร้าง · `🟨` ส่ง code แล้วรอสร้าง · `🟦` activate แล้วรอ push · `✅` อยู่ใน repo

`🔒` = release C1 (Use in Cloud Development + Use in Key User Apps)

## Data foundation

| Object | Type | ไฟล์ | Status |
|---|---|---|---|
| `ZBCPARAM` | Package (superpackage `ZCUSTOM_DEVELOPMENT` · encapsulated) | `src/package.devc.xml` | ✅ baseline `5475564` |
| `ZTBC_PARAM` 🔒 | Table — constant parameter | `src/ztbc_param.tabl.xml` | ✅ `5475564` |
| `ZSBC_PARAM_KEY` 🔒 | Structure — key (`COMPANY_CODE` · `MODULE_ID` · `APP_ID` · `PARAM_NAME` · `PARAM_EXT` · `SEQUENCE` · `END_DATE`) | `src/zsbc_param_key.tabl.xml` | ✅ `5475564` |
| `ZSBC_PARAM_FIELD` 🔒 | Structure — `START_DATE` · `PARAM_SIGN` · `PARAM_OPTION` · `LOW_VALUE` · `HIGH_VALUE` · `PARAM_DESC` | `src/zsbc_param_field.tabl.xml` | ✅ `5475564` |
| `ZSBC_PARAM_ADMIN` 🔒 | Structure — created / last changed | `src/zsbc_param_admin.tabl.xml` | ✅ `5475564` |
| `ZE_APP_ID` · `ZE_PARAM_NAME` · `ZE_PARAM_EXT` · `ZE_MODULE_ID` · `ZE_SEQUENCE_NO` · `ZE_LOW_VALUE` · `ZE_HIGH_VALUE` · `ZE_PARAM_DESC` 🔒 | Data element | `src/ze_*.dtel.xml` | ✅ `5475564` |
| `ZD_MODULE_ID` · `ZD_SEQUENCE_NO` · `ZD_PARAM_VALUE` · `ZD_PARAM_DESC` 🔒 | Domain | `src/zd_*.doma.xml` | ✅ `5475564` |

## Utility

| Object | Type | ไฟล์ | Status |
|---|---|---|---|
| `ZCL_PARAM` 🔒 | Class — `create_instance( )` · `get_value( )` · `get_range( )` · `gt_param` READ-ONLY | `src/zcl_param.clas.abap` | ✅ `5475564` · `previous` + ABAP Doc `947668b` `4e933f6` · ย้าย `sanitize` ไป `ZCL_UTILITY` `8cb234f` · release C1 กลับ `0d83999` |
| `ZCX_PARAM` 🔒 | Exception class — reason `NOT_FOUND` · `INVALID_PARAM` · `INVALID_TYPE` | `src/zcx_param.clas.abap` | ✅ `5475564` · `ELSE` ใน `get_text` + ABAP Doc `947668b` |
| `ZCL_PARAM_DEMO` | Class `IF_OO_ADT_CLASSRUN` — Sample 1-9 · ไม่ release | `src/zcl_param_demo.clas.abap` | ✅ `1240efb` |

## Maintenance app (RAP business configuration)

| Object | Type | ไฟล์ | Status |
|---|---|---|---|
| `ZI_CONSTANTPARAMETER` | CDS view entity + access control + metadata extension | `src/zi_constantparameter.*` | ✅ `5475564` |
| `ZI_CONSTANTPARAMETER_S` | CDS singleton root + BDEF | `src/zi_constantparameter_s.*` | ✅ `5475564` |
| `ZBP_I_CONSTANTPARAMETER_S` | Behavior pool | `src/zbp_i_constantparameter_s.clas.*` | ✅ `5475564` |
| `ZTBC_PARAM_D` · `ZTBC_PARAM_D_S` | Draft table | `src/ztbc_param_d*.tabl.xml` | ✅ `5475564` |
| `ZUI_CONSTANTPARAMETER` · `ZUI_CONSTANTPARAMETER_O4` | Service definition · binding (OData V4) | `src/zui_constantparameter*` | ✅ `5475564` |
| `ZCONSTANTPARAMETER` | Business configuration maintenance object — Fiori "Maintain Constant Parameter" · transport object `ZCONSTANTPARAMETERT` | `src/zconstantparameter.smbc.json` | ✅ `5475564` |
| `ZBC_ZBCPARAM` · `ZIAM_ZBCPARAM_MBC` · `ZBC_ZBCPARAM_0001` | Business catalog · IAM app · catalog assignment | `src/*.sia1.xml` · `src/*.sia6.xml` · `src/*.sia7.xml` | ✅ `5475564` |
| ไฟล์ที่ระบบ generate มากับ maintenance app | authorization default (`SUSH`) · service binding artifact (`SCO2`) | `src/efc78c6ba3f600ce7a3658e7856a29ht.sush.xml` · `src/zui_constantparameter_o4_0001_g4ba.sco2.xml` | ✅ `5475564` · ห้ามแก้มือ |

## Consumer

| ผู้เรียก | ใช้อะไร | หมายเหตุ |
|---|---|---|
| **Custom Logic (key user) บน tenant** | `ZCL_PARAM` · `ZCX_PARAM` เรียกตรง | เหตุผลที่ต้อง release C1 + Use in Key User Apps · ไม่ใช้ `sanitize` (ผู้ใช้เช็ค 2026-10-06) |
| ZIME001 — `ZCL_ZIME001` | `create_instance( )` + `get_range( )` | อ่าน `MM / IME001 / PRODUCTION_ORDER_TYPE` · repo `fplus-zime001` |
| ZBCUTILITY — `zcl_utility=>get_local_datetime( )` | `create_instance( )` + `get_value( )` | อ่าน `BC / UTILITY / TIMEZONE / LOCAL` · repo `fplus-zbcutility` · พึ่งกันสองทาง ดู `CLAUDE.md` |

## Dependency ออกไปข้างนอก

| ใช้ของจาก | อะไร | ผล |
|---|---|---|
| `ZBCUTILITY` | `zcl_utility=>remove_invisible_char( )` ใน constructor ของ `ZCL_PARAM` | transport ต้องไปพร้อม `ZBCUTILITY` · ดู `CLAUDE.md` |
