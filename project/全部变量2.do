* 2025/4/8
clear
cd "D:\CodeEconomicproject\GVC_PY"

**# GVC成立省份和市级层面规模
// 省级层面
import delimited ".\data\基金成立\GVC成立信息.csv", clear
gen Year = substr(成立时间,1,4)
destring Year 目标规模人民币百万,replace force
bysort Year 地区一级: egen IndFundSize1 = sum(目标规模人民币百万)
duplicates drop Year 地区一级,force
replace IndFundSize1 = IndFundSize1*100
replace IndFundSize1 = log(IndFundSize1)
keep Year 地区一级 IndFundSize1
sort 地区一级 Year
drop if 地区一级==""
gen Province = 地区一级
save .\input\省级层面GVC成立规模.dta,replace
// 市级层面
import delimited ".\data\基金成立\GVC成立信息.csv", clear
gen Year = substr(成立时间,1,4)
destring Year 目标规模人民币百万,replace force
bysort Year 地区一级 地区二级: egen IndFundSize2 = sum(目标规模人民币百万)
duplicates drop Year 地区一级 地区二级,force
replace IndFundSize2 = IndFundSize*100
replace IndFundSize2 = log(IndFundSize2)
keep Year 地区一级 地区二级 IndFundSize2
sort 地区一级 地区二级 Year
drop if 地区二级==""
drop if Year == .
gen City = 地区二级
save .\input\市级层面GVC成立规模.dta,replace

**# 企业基本信息
// 地区，行业
import excel using .\data\上市公司信息\上市公司基本信息年度表\STK_LISTEDCOINFOANL.xlsx, firstrow clear
drop if _n == 1 | _n == 2
gen Year = substr(EndDate,1,4)
destring Symbol Year,replace
gen Province = PROVINCE
gen City = CITY
replace Province = "内蒙古自治区" if Province == "内蒙古"
replace Province = "宁夏回族自治区" if Province == "宁夏"
replace Province = "广西壮族自治区" if Province == "广西"
replace Province = "新疆维吾尔自治区" if Province == "新疆"
replace Province = "西藏自治区" if Province == "西藏"
gen Ind2012 = IndustryName
keep Symbol Year Province City Ind2012 
save .\input\上市公司地区和行业信息.dta,replace
// 企业代码与全称对应
import excel using .\data\上市公司信息\上市公司基本信息年度表\STK_LISTEDCOINFOANL.xlsx, firstrow clear
drop if _n == 1 | _n == 2
destring Symbol ,replace
keep Symbol FullName SocialCreditCode
duplicates drop Symbol, force
save .\input\企业代码与全称对应.dta,replace
// 公司停牌
import excel using .\data\上市公司信息\因子研究系列-股票流动性-个股停牌标识表-全部代码\LIQ_SUSPENSION.xlsx, firstrow clear
drop if _n == 1 | _n == 2
keep if ST == "Y"
rename Stkcd Symbol
gen Year = substr(Suspdate,1,4)
keep Symbol Year ST
destring Symbol Year,replace force
save .\input\企业ST信息.dta,replace

**# 企业专利信息
// CNRDS上市公司获得与申请情况
import excel using .\data\专利数据\CNRDS\上市公司专利获得与申请情况.xlsx, firstrow clear
keep if 公司类型=="上市公司本身"
gen PatentApply = 当年独立申请的发明数量 
gen PatentGet = 当年独立获得的发明数量
gen Year = 会计年度
gen Symbol = 股票代码
keep PatentApply PatentGet Year Symbol
save .\input\CNRDS上市公司获得与申请情况.dta,replace
// 学人师兄数据
import delimited ".\data\专利数据\学人师兄数据\上市公司专利统计.csv", clear
split stkcd,p("_")
rename stkcd2 Symbol
rename year Year
rename v3 Patent
keep Year Symbol Patent
destring Symbol, replace
save .\input\XR上市公司专利统计.dta,replace
// 省级层面统计专利数据(全部企业)
use .\input\CNRDS上市公司获得与申请情况.dta,clear
merge 1:1 Symbol Year using .\input\XR上市公司专利统计.dta,nogen
merge 1:1 Symbol Year using .\input\上市公司地区和行业信息.dta,nogen // 公司会改名
replace Patent = 0 if Patent == .
bysort Symbol(Symbol Year): replace Province = Province[_n-1] if missing(Province)
bysort Symbol(Symbol Year): replace Province = Province[_N] if missing(Province)
bysort Year Province: egen PatentProvince1 = sum(Patent)
bysort Year Province: egen PatentProvince2 = sum(PatentApply)
bysort Year Province: egen PatentProvince3 = sum(PatentGet)
duplicates drop Year Province,force
keep Year Province PatentProvince1-PatentProvince3
save .\input\省级层面专利统计.dta,replace
// 市级层面统计专利数据(全部企业)
use .\input\CNRDS上市公司获得与申请情况.dta,clear
merge 1:1 Symbol Year using .\input\XR上市公司专利统计.dta,nogen
merge 1:1 Symbol Year using .\input\上市公司地区和行业信息.dta,nogen // 公司会改名
replace Patent = 0 if Patent == .
bysort Symbol(Symbol Year): replace Province = Province[_n-1] if missing(Province)
bysort Symbol(Symbol Year): replace Province = Province[_N] if missing(Province)
bysort Symbol(Symbol Year): replace City = City[_n-1] if missing(City)
bysort Symbol(Symbol Year): replace City = City[_N] if missing(City)
bysort Year City: egen PatentCity1 = sum(Patent)
bysort Year City: egen PatentCity2 = sum(PatentApply)
bysort Year City: egen PatentCity3 = sum(PatentGet)
duplicates drop Year City ,force
keep Year Province City PatentCity1-PatentCity3
save .\input\市级层面专利统计.dta,replace
// 省级层面统计专利数据(被GVC投资过企业)
use .\input\CNRDS上市公司获得与申请情况.dta,clear
merge 1:1 Symbol Year using .\input\XR上市公司专利统计.dta,nogen
replace Patent = 0 if Patent == .
merge m:1 Symbol using .\input\企业代码与全称对应.dta,nogen
drop if Symbol == . 
merge 1:1 Symbol Year using .\input\上市公司地区和行业信息.dta,nogen // 公司会改名
drop if FullName == ""
duplicates drop FullName Year, force
merge 1:1 FullName Year using .\input\企业投资事件统计.dta
drop if _merge == 2
drop _merge
replace GVC_num=0 if GVC_num==.
replace VC_num=0 if VC_num==.
bysort Symbol:egen GVC_dummy = sum(GVC_num) // 分组变量GVC，若公司获得政府引导基金出资成立的风投机构的投资则取1
replace GVC_dummy = 1 if GVC_dummy>1
keep if GVC_dummy == 1 
bysort Symbol(Symbol Year): replace Province = Province[_n-1] if missing(Province)
bysort Symbol(Symbol Year): replace Province = Province[_N] if missing(Province)
bysort Year Province: egen PatentProvince1 = sum(Patent)
bysort Year Province: egen PatentProvince2 = sum(PatentApply)
bysort Year Province: egen PatentProvince3 = sum(PatentGet)
duplicates drop Year Province,force
keep Year Province PatentProvince1-PatentProvince3
save .\input\省级层面被GVC投资企业专利统计.dta,replace
// 市级层面统计专利数据(被GVC投资过企业)
use .\input\CNRDS上市公司获得与申请情况.dta,clear
merge 1:1 Symbol Year using .\input\XR上市公司专利统计.dta,nogen
replace Patent = 0 if Patent == .
merge m:1 Symbol using .\input\企业代码与全称对应.dta,nogen
drop if Symbol == . 
merge 1:1 Symbol Year using .\input\上市公司地区和行业信息.dta,nogen // 公司会改名
drop if FullName == ""
duplicates drop FullName Year, force
merge 1:1 FullName Year using .\input\企业投资事件统计.dta
drop if _merge == 2
drop _merge
replace GVC_num=0 if GVC_num==.
replace VC_num=0 if VC_num==.
bysort Symbol:egen GVC_dummy = sum(GVC_num) // 分组变量GVC，若公司获得政府引导基金出资成立的风投机构的投资则取1
replace GVC_dummy = 1 if GVC_dummy>1
keep if GVC_dummy == 1 
bysort Symbol(Symbol Year): replace Province = Province[_n-1] if missing(Province)
bysort Symbol(Symbol Year): replace Province = Province[_N] if missing(Province)
bysort Symbol(Symbol Year): replace City = City[_n-1] if missing(City)
bysort Symbol(Symbol Year): replace City = City[_N] if missing(City)
bysort Year City: egen PatentCity1 = sum(Patent)
bysort Year City: egen PatentCity2 = sum(PatentApply)
bysort Year City: egen PatentCity3 = sum(PatentGet)
duplicates drop Year City ,force
keep Year Province City PatentCity1-PatentCity3
save .\input\市级层面被GVC投资企业专利统计.dta,replace

**# 企业投资事件统计
use ./data/风投数据/清科和CVS投资事件和爱企查企业工商信息.dta, clear
replace 基金分类 = "其他基金" if 基金分类 == ""
tab 基金分类
rename year Year
gen GVC_dummy = (基金分类=="PPP" | 基金分类=="产业基金" | 基金分类=="创业投资基金" )
gen VC_dummy = (基金分类=="其他基金" )
bysort Year 企业名称: egen GVC_num = sum(GVC_dummy)
bysort Year 企业名称: egen VC_num = sum(VC_dummy)
duplicates drop 企业名称 Year , force
keep Year 企业名称 GVC_num VC_num
sort 企业名称 Year
rename 企业名称 FullName
save .\input\企业投资事件统计.dta,replace

**# 控制变量：公司层面财务控制变量（CSMAR,Year,上市公司）
// 研发投入
import excel using .\data\上市公司信息\上市公司研发创新-研发投入情况\PT_LCRDSPENDING.xlsx, firstrow clear
drop if _n == 1 | _n == 2
destring Symbol- Explanation,replace
keep if StateTypeCode == 1 // 合并会计报表
gen RD = RDSpendSum // 研发投入金额
gen RDSRatio = RDSpendSumRatio // 研发投入占营业收入比例(%)
gen Year = substr(EndDate,1,4)
destring Year,force replace
keep Symbol Year RD RDSRatio
duplicates drop Symbol Year,force
save .\input\上市公司研发投入.dta,replace
// 财务等信息
import excel using .\data\上市公司信息\企业年财务数据\智能查询_沪深京股票.xlsx, firstrow clear
drop if _n == 1 | _n == 2
gen Size = FS_CombasA001000000
gen ROA = AIQ_LCFinIndexYROTAA
gen Lev = FI_T7F070201B
gen Growth = BDT_ExcessiveDebtGrowth
gen Cash = FI_T1F010401A
gen MB = FI_T10F101001A
gen Tang = FI_T3F031001A
gen Age = BDT_FinConstFCListingAge
gen Boardsize = CG_ManagerShareSalary
gen Balance = BDT_ManaGovAbilSharesBalance
gen InsInvest = INI_HolderSystematicsInsInvesto
gen ManShare = BDT_ManaGovAbilMngmhldn
gen IndDirector = BDT_ManaGovAbilIndDirectorRatio
gen Dual = BDT_ManaGovAbilConcurrentPositi
rename EndDate Year
rename code Symbol
destring Symbol Year Size-Dual Growth,replace force
keep Symbol Year Size-Dual Growth
save .\input\上市公司财务信息.dta,replace

**# 控制变量：投资层面
use ./data/风投数据/清科和CVS投资事件和爱企查企业工商信息.dta, clear
drop if 查询名称=="匹配分数＜15"
rename year Year
gen Ind2001= 行业分类2001
gen SocialCreditCode = 统一社会信用代码
gen FullName = 企业名称
keep Year SocialCreditCode FullName Ind2001 round_num1- round_num29
sort FullName Year
duplicates drop FullName Year,force
save .\input\控制变量_投资轮次和2001年公司行业分类.dta,replace

**# 控制变量：省份GDP
use ./data/上市公司信息/宏观控制变量/CRE_Gdp01.dta,clear
rename year Year
rename firm_province Province
save .\input\控制变量_省份GDP.dta,replace

**# 全部变量1：省级和市级层面宏观数据
// 省级层面
use .\input\省级层面GVC成立规模.dta,clear
merge 1:1 Year Province using .\input\省级层面被GVC投资企业专利统计.dta,nogen
merge 1:1 Year Province using .\input\控制变量_省份GDP.dta
keep if _merge == 3
drop _merge
keep Province Year IndFundSize1 PatentProvince1-PatentProvince3 Gdp0101 Gdp0116
sum 
save .\input\全部变量1_省级层面宏观数据.dta,replace
// 市级层面
use .\input\市级层面GVC成立规模.dta,clear
merge 1:1 Year City using .\input\市级层面被GVC投资企业专利统计.dta,nogen
merge m:1 Year Province using .\input\控制变量_省份GDP.dta
keep if _merge == 3
drop _merge
keep Province City Year IndFundSize2 PatentCity1-PatentCity3 Gdp0101 Gdp0116
sum 
save .\input\全部变量1_市级层面宏观数据.dta,replace

**# 全部变量2：企业层面变量
use .\input\CNRDS上市公司获得与申请情况.dta,clear
merge 1:1 Symbol Year using .\input\XR上市公司专利统计.dta,nogen
replace Patent = 0 if Patent == .
merge 1:1 Symbol Year using .\input\上市公司财务信息.dta
keep if _merge == 3
drop _merge
merge 1:1 Symbol Year using .\input\上市公司研发投入.dta,nogen
merge 1:1 Symbol Year using .\input\上市公司地区和行业信息.dta
drop if _merge == 2
drop _merge
merge m:1 Province Year using .\input\省级层面GVC成立规模.dta
drop if _merge == 2
drop _merge
merge m:1 City Year using .\input\市级层面GVC成立规模.dta
drop if _merge == 2
drop _merge
merge m:1 Symbol using .\input\企业代码与全称对应.dta,nogen
drop if Symbol == . 
drop if FullName == ""
sort Symbol Year
duplicates examples FullName Year
duplicates drop FullName Year,force
merge 1:1 FullName Year using .\input\控制变量_投资轮次和2001年公司行业分类.dta
drop if _merge == 2
drop _merge
merge 1:1 FullName Year using .\input\企业投资事件统计.dta
drop if _merge == 2
drop _merge
merge 1:m Symbol Year using .\input\企业ST信息.dta,nogen
drop if ST == "Y"
egen miss = rowmiss(Size ROA Lev Growth Cash MB Tang Age Boardsize Balance InsInvest ManShare IndDirector Dual RD Patent PatentGet PatentApply)
drop if miss > 0
drop miss
replace GVC_num=0 if GVC_num==.
replace VC_num=0 if VC_num==.
save .\input\面板数据2_上市公司.dta,replace
