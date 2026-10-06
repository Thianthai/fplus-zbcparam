# ZBCPARAM — Constant Parameter

ใช้กฎกลางใน `~/.claude/CLAUDE.md` ทุกข้อ · prefix `Z*` (case by case ตามที่ตกลงกับ RICEFW ทั้งชุด fplus)

## API ของ key user — แก้ได้เฉพาะแบบ compatible

`ZCL_PARAM` และ `ZCX_PARAM` release **C1 · Use in Cloud Development · Use in Key User Apps**
และมี **Custom Logic (key user) เรียกใช้ตรงอยู่บน tenant** (ผู้ใช้ยืนยัน 2026-10-06 · ไม่บันทึกชื่อ Custom Logic)

| ทำได้ | ห้ามทำ |
|---|---|
| เพิ่ม method ใหม่ | ลบ / เปลี่ยนชื่อ method หรือ parameter |
| เพิ่ม parameter แบบ `OPTIONAL` | เปลี่ยน type ของ parameter / type ที่ public |
| เพิ่ม constant ใน `ZCX_PARAM=>gc_reason` | เปลี่ยน optional เป็น mandatory |
| แก้ implementation / ABAP Doc | ลบหรือเปลี่ยนค่า reason ที่มีอยู่ |

- C1 บังคับให้ type ที่โผล่ใน public signature release ตาม → `ZTBC_PARAM` + structure / data element / domain ทั้งหมด release C1 ด้วย
- ถ้าจำเป็นต้องแก้แบบ incompatible จริง ต้องถอน release ก่อน แก้ แล้ว release ใหม่ **และเช็ค Custom Logic บน tenant ก่อนเสมอ**
  (เคสจริง: ลบ `sanitize` 2026-10-06 — ผ่านได้เพราะไม่มี Custom Logic เรียก `sanitize`)
- release ถูกกดตั้งแต่ก่อนจะมี repo นี้ โดยคนที่ใช้ใน Custom Logic — ไม่ได้เกิดจาก ZIME001
  (`ZCL_ZIME001` เรียก `ZCL_PARAM` แค่ใน implementation ซึ่งไม่ต้อง release)
- ไฟล์ API state ชื่อ `src/zcl_param<ช่องว่าง>clas.apis.xml` (SAP ใช้ key แบบ padded) **ห้าม rename**
- `ZCL_PARAM_DEMO` **ไม่ release** — ไม่ใช่ API · ข้อมูลที่ demo อ่านต้องมีอยู่บน tenant

## การออกแบบ `ZCL_PARAM` ที่ตั้งใจ

- **`CREATE PRIVATE` + `create_instance( )`** — constructor ต้องรู้ว่า parameter ไหน "ไม่ส่ง" (ไม่กรอง) ต่างจาก "ส่งค่าว่าง"
  `create_instance` จึงแยก 4 เคสตาม `IS SUPPLIED` แล้วค่อย `NEW` · ห้ามส่งต่อทุกตัวรวดเดียว
- `IS SUPPLIED` ส่งต่อเข้า private method ไม่ได้ → `filter_param` รับ flag `iv_has_*` คู่กับค่าเสมอ
- `get_value` / `get_range` ใช้ `EXPORTING ... TYPE any / STANDARD TABLE` เพื่อให้ caller รับด้วย type ของตัวเอง
  (RETURNING เป็น generic ไม่ได้) · แลกกับการเขียน inline `DATA(x) = ...` ไม่ได้
- ไม่พบ / maintain ไม่ครบ / แปลง type ไม่ได้ → raise `ZCX_PARAM` · constructor **ไม่ raise** (ตกลง 2026-08 เพื่อให้ `create_instance` ใช้ง่าย)

## พึ่ง `ZBCUTILITY` สองทาง (ตั้งแต่ 2026-10-06)

| ทิศทาง | ผู้เรียก | ถูกเรียก |
|---|---|---|
| `ZBCPARAM` -> `ZBCUTILITY` | constructor ของ `ZCL_PARAM` | `zcl_utility=>remove_invisible_char( )` ล้าง key field ของ buffer (ย้ายมาจาก `sanitize` `8cb234f`) |
| `ZBCUTILITY` -> `ZBCPARAM` | `zcl_utility=>get_local_datetime( )` | `ZCL_PARAM` อ่าน `BC / UTILITY / TIMEZONE / LOCAL` |

- **Transport:** อยู่ software component `ZCUSTOM_DEVELOPMENT` เดียวกัน · **release TR ของทั้ง 2 package ให้ครบก่อน แล้วค่อย import**
- **`ZCL_UTILITY` ไม่ต้อง release** — Custom Logic เรียก `ZCL_PARAM` ส่วน `ZCL_UTILITY` อยู่แค่ใน implementation
- **ห้ามวนกลับ:** method ใดที่ `ZCL_PARAM` เรียก ห้ามเรียก `ZCL_PARAM` กลับ เพราะถูกเรียกจาก constructor → ทุก `create_instance( )` จะวนซ้ำจน dump
  · ด้วยเหตุนี้ `ZCL_PARAM` **ห้ามใช้ `zcl_utility=>get_local_datetime( )`**
- กฎเรื่อง release ข้าม package แบบละเอียดอยู่ใน `fplus-zbcutility/CLAUDE.md` หัวข้อ Release C1

## Validity date — ข้อจำกัดที่รับไว้

- constructor หาวันนี้จาก `cl_abap_context_info=>get_user_time_zone( )` แต่บน tenant ฟังก์ชันนี้**คืน UTC เสมอ**
  → validity ถูกกรองด้วยวันที่ UTC · ช่วง 00:00-06:59 เวลาไทยยังเป็นวันของเมื่อวาน
- ผู้ใช้ตัดสินใจ **ไม่แก้** 2026-10-06 · ถ้าจะแก้ในอนาคต ให้อ่าน timezone จาก `ZTBC_PARAM` เอง (SELECT ตรง) ห้ามผ่าน `ZCL_UTILITY`

## Git

| สิ่งที่ทำ | ใคร |
|---|---|
| ABAP object | ผู้ใช้ push ผ่าน abapGit จาก ADT |
| เอกสาร | Claude commit + push เอง |

- Remote: https://github.com/Thianthai/fplus-zbcparam.git
- repo เดิม `demo-zbcparam` เลิกใช้แล้ว
