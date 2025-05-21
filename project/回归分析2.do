* 2025/3/23
clear
cd "D:\CodeEconomicproject\GVC_PY"

**# 全部企业：地方产业引导基金与域内企业创新投入
import delimited ".\input\面板数据2_全部企业.csv", clear
gen Firm = 企业名称
gen Year = year_x
gen IndFundSize1 = indfundsize1 // 省级
gen IndFundSize2 = indfundsize2 // 市级
gen Province = 所属省份
gen City = 所属城市
gen Patent = 专利数量
gen Ind = 所属行业
keep Patent IndFundSize2 Province Year Ind
replace IndFundSize2=0 if IndFundSize2==.
// winsor
winsor Patent, p(0.01) gen(Patent_x)
drop Patent
rename Patent_x Patent
sum Patent IndFundSize2
// 回归结果
reghdfe Patent IndFundSize2 , abs(Province Year)
 outreg2 using ./output/Table_地方产业引导基金与域内企业创新投入.rtf, tstat bdec(3) tdec(2) addtext("Province", "Yes" ,"Ind", "No" ,"Year","Yes") adjr2 nonote replace
reghdfe Patent IndFundSize2 , abs(Ind Year)
 outreg2 using ./output/Table_地方产业引导基金与域内企业创新投入.rtf, tstat bdec(3) tdec(2) addtext("Province", "No" ,"Ind", "Yes" ,"Year","Yes") adjr2 nonote append

 **# 上市企业：地方产业引导基金与域内企业创新投入
use .\input\面板数据2_上市公司.dta,clear
local Control Size ROA Lev Growth Cash MB Tang Age Boardsize Balance InsInvest ManShare IndDirector Dual
replace RD = log(RD)
// replace IndFundSize2=0 if IndFundSize2==.
replace Patent = 0 if Patent == .
// winsor
local vv "Size ROA Lev Growth Cash MB Tang Age Boardsize Balance InsInvest ManShare IndDirector Dual RD Patent PatentGet PatentApply"
     foreach v of varlist `vv'{
    winsor `v', p(0.01) gen(`v'_x)
    drop `v'
    rename `v'_x `v'
     }
foreach var of varlist _all {
	label var `var' ""
}
sum Size ROA Lev Growth Cash MB Tang Age Boardsize Balance InsInvest ManShare IndDirector Dual RD Patent PatentGet PatentApply IndFundSize2

// 回归
reghdfe RD IndFundSize2 $Control, abs(Province Year)
 outreg2 using ./output/Table_地方产业引导基金与域内企业创新投入.rtf, tstat bdec(3) tdec(2) addtext("Province", "Yes" ,"Ind", "No" ,"Year","Yes") adjr2 nonote append
reghdfe Patent IndFundSize2 $Control, abs(Province Year)
 outreg2 using ./output/Table_地方产业引导基金与域内企业创新投入.rtf, tstat bdec(3) tdec(2) addtext("Province", "Yes" ,"Ind", "No" ,"Year","Yes") adjr2 nonote append
reghdfe PatentGet  IndFundSize2 $Control, abs(Province Year)
 outreg2 using ./output/Table_地方产业引导基金与域内企业创新投入.rtf, tstat bdec(3) tdec(2) addtext("Province", "Yes" ,"Ind", "No" ,"Year","Yes") adjr2 nonote append
reghdfe PatentApply IndFundSize2 $Control, abs(Province Year)
 outreg2 using ./output/Table_地方产业引导基金与域内企业创新投入.rtf, tstat bdec(3) tdec(2) addtext("Province", "Yes" ,"Ind", "No" ,"Year","Yes") adjr2 nonote append
reghdfe RD IndFundSize2 $Control, abs(Ind Year)
 outreg2 using ./output/Table_地方产业引导基金与域内企业创新投入.rtf, tstat bdec(3) tdec(2) addtext("Province", "No" ,"Ind", "Yes" ,"Year","Yes") adjr2 nonote append
reghdfe Patent IndFundSize2 $Control, abs(Ind Year)
 outreg2 using ./output/Table_地方产业引导基金与域内企业创新投入.rtf, tstat bdec(3) tdec(2) addtext("Province", "No" ,"Ind", "Yes" ,"Year","Yes") adjr2 nonote append
reghdfe PatentGet  IndFundSize2 $Control, abs(Ind Year)
 outreg2 using ./output/Table_地方产业引导基金与域内企业创新投入.rtf, tstat bdec(3) tdec(2) addtext("Province", "No" ,"Ind", "Yes" ,"Year","Yes") adjr2 nonote append
reghdfe PatentApply IndFundSize2 $Control, abs(Ind Year)
 outreg2 using ./output/Table_地方产业引导基金与域内企业创新投入.rtf, tstat bdec(3) tdec(2) addtext("Province", "No" ,"Ind", "Yes" ,"Year","Yes") adjr2 nonote append

**# 全部企业：DID回归，GVC投资对企业创新的影响 
import delimited ".\input\面板数据1_全部企业.csv", clear
// 处理变量
sort 申请人 专利year
bysort 申请人: gen num111 = _N
drop if num111<10
keep if strpos(申请人, "公司") > 0
drop 企业名称 year
rename 申请人 企业名称
rename 专利year year
rename 专利数量 Patent
gen GVC投资次数 = 产业基金投资次数+创业投资基金投资次数+ppp基金投资次数
gen 普通VC投资 = 其他基金投资次数
// 生成DID变量
bysort 企业名称:egen GVC_dummy = sum(GVC投资次数) // 分组变量GVC，若公司获得政府引导基金出资成立的风投机构的投资则取1
replace GVC_dummy = 1 if GVC_dummy>1
bysort 企业名称:egen VC_dummy = sum(普通VC投资) // 分组变量VC，若公司获得普通基金出资成立的风投机构的投资则取1
replace VC_dummy = 1 if VC_dummy>1
bysort 企业名称:gen GVC_sum = sum(GVC投资次数) 
bysort 企业名称:gen VC_sum = sum(普通VC投资) 
bysort 企业名称:egen GVC_min = min(GVC_sum)
bysort 企业名称:egen VC_min = min(VC_sum)
gen GVC_post = (GVC_sum>GVC_min) 
gen VC_post = (VC_sum>VC_min) 
gen DID_GVC = GVC_dummy*GVC_post
gen DID_VC = VC_dummy*VC_post 
//winsor
winsor Patent, p(0.01) gen(Patent_x)
drop Patent
rename Patent_x Patent
drop if Patent==.
sum Patent DID_GVC DID_VC GVC_dummy GVC_post VC_dummy VC_post
// 回归
reghdfe Patent DID_GVC DID_VC, abs(企业名称 year)
 outreg2 using ./output/Table_企业GVC对创新的影响.rtf, tstat bdec(3) tdec(2) addtext("Firm", "Yes" ,"Year","Yes") adjr2 nonote replace

**# 上市企业：DID回归，GVC投资对企业创新的影响 
import delimited ".\input\面板数据1_全部企业.csv", clear
// 处理变量
sort 申请人 专利year
bysort 申请人: gen num111 = _N
drop if num111<10
keep if strpos(申请人, "公司") > 0
drop 企业名称 year
rename 申请人 企业名称
rename 专利year year
rename 专利数量 Patent
gen GVC投资次数 = 产业基金投资次数+创业投资基金投资次数+ppp基金投资次数
gen 普通VC投资 = 其他基金投资次数
drop _merge
recast str255 企业名称
// 合并基金的退出数据
merge 1:m 企业名称 year using .\data\风投数据\1990-2023私募通退出事件.dta
drop if _merge==2
drop _merge
gen IPO_dummy = 1 if 退出方式 =="IPO"
bysort 企业名称: egen IPO_num =sum(IPO_dummy)
drop if IPO_num==0 | IPO_num==.
duplicates drop 企业名称 year,force
// 生成DID变量
bysort 企业名称:egen GVC_dummy = sum(GVC投资次数) // 分组变量GVC，若公司获得政府引导基金出资成立的风投机构的投资则取1
replace GVC_dummy = 1 if GVC_dummy>1
bysort 企业名称:egen VC_dummy = sum(普通VC投资) // 分组变量VC，若公司获得普通基金出资成立的风投机构的投资则取1
replace VC_dummy = 1 if VC_dummy>1
bysort 企业名称:gen GVC_sum = sum(GVC投资次数) 
bysort 企业名称:gen VC_sum = sum(普通VC投资) 
bysort 企业名称:egen GVC_min = min(GVC_sum)
bysort 企业名称:egen VC_min = min(VC_sum)
gen GVC_post = (GVC_sum>GVC_min) 
gen VC_post = (VC_sum>VC_min) 
gen DID_GVC = GVC_dummy*GVC_post
gen DID_VC = VC_dummy*VC_post 
//winsor
winsor Patent, p(0.01) gen(Patent_x)
drop Patent
rename Patent_x Patent
drop if Patent==.
sum Patent DID_GVC DID_VC GVC_dummy GVC_post VC_dummy VC_post
// 回归
reghdfe Patent DID_GVC DID_VC, abs(企业名称 year)
 outreg2 using ./output/Table_企业GVC对创新的影响.rtf, tstat bdec(3) tdec(2) addtext("Firm", "Yes" ,"Year","Yes") adjr2 nonote append
