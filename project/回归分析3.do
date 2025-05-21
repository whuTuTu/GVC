* 2025/3/23
clear
cd "D:\CodeEconomicproject\GVC_PY"

 **# 上市企业：地方产业引导基金与域内企业创新投入
use .\input\面板数据2_上市公司.dta,clear
local Control Size ROA Lev Growth Cash MB Tang Age Boardsize Balance InsInvest ManShare IndDirector Dual
replace IndFundSize2=0 if IndFundSize2==.
replace Patent = 0 if Patent == .
// winsor
local vv "Size ROA Lev Growth Cash MB Tang Age Boardsize Balance InsInvest ManShare IndDirector Dual RD Patent PatentGet PatentApply RD"
     foreach v of varlist `vv'{
    winsor `v', p(0.01) gen(`v'_x)
    drop `v'
    rename `v'_x `v'
     }
foreach var of varlist _all {
	label var `var' ""
}
sum Size ROA Lev Growth Cash MB Tang Age Boardsize Balance InsInvest ManShare IndDirector Dual RD Patent PatentGet PatentApply IndFundSize2
gen lnRD = log(RD)
// 创新投入回归
reghdfe lnRD IndFundSize2 $Control, abs(Province Year)
 outreg2 using ./output/Table_地方产业引导基金与域内企业创新投入.rtf, tstat bdec(3) tdec(2) addtext("Province", "Yes" ,"Ind", "No" ,"Year","Yes") adjr2 nonote replace
reghdfe lnRD IndFundSize2 $Control, abs(Ind Year)
 outreg2 using ./output/Table_地方产业引导基金与域内企业创新投入.rtf, tstat bdec(3) tdec(2) addtext("Province", "No" ,"Ind", "Yes" ,"Year","Yes") adjr2 nonote append
reghdfe RDSRatio IndFundSize2 $Control, abs(Province Year)
 outreg2 using ./output/Table_地方产业引导基金与域内企业创新投入.rtf, tstat bdec(3) tdec(2) addtext("Province", "Yes" ,"Ind", "No" ,"Year","Yes") adjr2 nonote append
reghdfe RDSRatio IndFundSize2 $Control, abs(Ind Year)
 outreg2 using ./output/Table_地方产业引导基金与域内企业创新投入.rtf, tstat bdec(3) tdec(2) addtext("Province", "No" ,"Ind", "Yes" ,"Year","Yes") adjr2 nonote append 

// 创新产出回归 
reghdfe Patent IndFundSize2 $Control, abs(Province Year) 
 outreg2 using ./output/Table_地方产业引导基金与域内企业创新产出.rtf, tstat bdec(3) tdec(2) addtext("Province", "Yes" ,"Ind", "No" ,"Year","Yes") adjr2 nonote replace
reghdfe Patent IndFundSize2 $Control, abs(Ind Year)
 outreg2 using ./output/Table_地方产业引导基金与域内企业创新产出.rtf, tstat bdec(3) tdec(2) addtext("Province", "No" ,"Ind", "Yes" ,"Year","Yes") adjr2 nonote append
reghdfe PatentGet IndFundSize2 $Control, abs(Province Year)
 outreg2 using ./output/Table_地方产业引导基金与域内企业创新产出.rtf, tstat bdec(3) tdec(2) addtext("Province", "Yes" ,"Ind", "No" ,"Year","Yes") adjr2 nonote append
reghdfe PatentGet IndFundSize2 $Control, abs(Ind Year)
 outreg2 using ./output/Table_地方产业引导基金与域内企业创新产出.rtf, tstat bdec(3) tdec(2) addtext("Province", "No" ,"Ind", "Yes" ,"Year","Yes") adjr2 nonote append
reghdfe PatentApply IndFundSize2 $Control, abs(Province Year)
 outreg2 using ./output/Table_地方产业引导基金与域内企业创新产出.rtf, tstat bdec(3) tdec(2) addtext("Province", "Yes" ,"Ind", "No" ,"Year","Yes") adjr2 nonote append
reghdfe PatentApply IndFundSize2 $Control, abs(Ind Year)
 outreg2 using ./output/Table_地方产业引导基金与域内企业创新产出.rtf, tstat bdec(3) tdec(2) addtext("Province", "No" ,"Ind", "Yes" ,"Year","Yes") adjr2 nonote append

// 创新效率回归
gen Patent_RD = Patent*100000000/RD
gen PatentApply_RD = PatentApply*100000000/RD
gen PatentGet_RD = PatentGet*100000000/RD
reghdfe Patent_RD IndFundSize2 $Control if Patent_RD!=0, abs(Province Year)
 outreg2 using ./output/Table_地方产业引导基金与域内企业创新效率.rtf, tstat bdec(3) tdec(2) addtext("Province", "Yes" ,"Ind", "No" ,"Year","Yes") adjr2 nonote replace
reghdfe Patent_RD IndFundSize2 $Control if Patent_RD!=0, abs(Ind Year)
 outreg2 using ./output/Table_地方产业引导基金与域内企业创新效率.rtf, tstat bdec(3) tdec(2) addtext("Province", "No" ,"Ind", "Yes" ,"Year","Yes") adjr2 nonote append
reghdfe PatentApply_RD IndFundSize2 $Control if PatentApply_RD!=0, abs(Province Year)
 outreg2 using ./output/Table_地方产业引导基金与域内企业创新效率.rtf, tstat bdec(3) tdec(2) addtext("Province", "Yes" ,"Ind", "No" ,"Year","Yes") adjr2 nonote append
reghdfe PatentApply_RD IndFundSize2 $Control if PatentApply_RD!=0, abs(Ind Year)
 outreg2 using ./output/Table_地方产业引导基金与域内企业创新效率.rtf, tstat bdec(3) tdec(2) addtext("Province", "No" ,"Ind", "Yes" ,"Year","Yes") adjr2 nonote append 
reghdfe PatentGet_RD IndFundSize2 $Control if PatentGet_RD!=0, abs(Province Year)
 outreg2 using ./output/Table_地方产业引导基金与域内企业创新效率.rtf, tstat bdec(3) tdec(2) addtext("Province", "Yes" ,"Ind", "No" ,"Year","Yes") adjr2 nonote append
reghdfe PatentGet_RD IndFundSize2 $Control if PatentGet_RD!=0, abs(Ind Year)
 outreg2 using ./output/Table_地方产业引导基金与域内企业创新效率.rtf, tstat bdec(3) tdec(2) addtext("Province", "No" ,"Ind", "Yes" ,"Year","Yes") adjr2 nonote append
sum
 
**# 上市企业：DID回归，GVC投资对企业创新的影响 
use .\input\面板数据1_上市公司.dta,clear
sum 
rename GVC_num GVC投资次数
rename VC_num 普通VC投资次数
rename FullName 企业名称
replace 普通VC投资次数 = 0 if 普通VC投资次数==.
replace GVC投资次数 = 0 if GVC投资次数==.
sum
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
// //winsor
// winsor Patent, p(0.01) gen(Patent_x)
// drop Patent
// rename Patent_x Patent
// drop if Patent==.
// sum Patent DID_GVC DID_VC GVC_dummy GVC_post VC_dummy VC_post
// 回归
reghdfe Patent DID_GVC DID_VC, abs(企业名称 Year)
 outreg2 using ./output/Table_企业GVC对创新的影响.rtf, tstat bdec(3) tdec(2) addtext("Firm", "Yes" ,"Year","Yes") adjr2 nonote replace
reghdfe PatentApply DID_GVC DID_VC, abs(企业名称 Year)
 outreg2 using ./output/Table_企业GVC对创新的影响.rtf, tstat bdec(3) tdec(2) addtext("Firm", "Yes" ,"Year","Yes") adjr2 nonote append
reghdfe PatentGet DID_GVC DID_VC, abs(企业名称 Year)
 outreg2 using ./output/Table_企业GVC对创新的影响.rtf, tstat bdec(3) tdec(2) addtext("Firm", "Yes" ,"Year","Yes") adjr2 nonote append

 
