@EndUserText.label: 'Constant Parameter'
@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
define view entity ZI_ConstantParameter
  as select from ztbc_param
  association to parent ZI_ConstantParameter_S as _ConstantParameteAll on $projection.SingletonID = _ConstantParameteAll.SingletonID
{
  key company_code as CompanyCode,
  key module_id as ModuleId,
  key app_id as AppId,
  key param_name as ParamName,
  key param_ext as ParamExt,
  key sequence as Sequence,
  key end_date as EndDate,
  start_date as StartDate,
  param_sign as ParamSign,
  param_option as ParamOption,
  low_value as LowValue,
  high_value as HighValue,
  param_desc as ParamDesc,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.lastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt,
  @Consumption.hidden: true
  1 as SingletonID,
  _ConstantParameteAll
}
