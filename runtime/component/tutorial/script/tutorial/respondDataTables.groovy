import org.moqui.impl.entity.EntityFacadeImpl;
import org.moqui.impl.entity.EntityFindImpl;
import org.moqui.impl.screen.ScreenUrlInfo;
/*
bRegex	false
bRegex_0	false
bRegex_1	false
bRegex_2	false
bSearchable_0	true
bSearchable_1	true
bSearchable_2	true
bSortable_0	true
bSortable_1	true
bSortable_2	true
iColumns	3
iDisplayLength	10
iDisplayStart	0
iSortCol_0	0
iSortingCols	1
mDataProp_0	tutorialId
mDataProp_1	description
mDataProp_2	lastUpdatedStamp
sColumns
sEcho	1
sSearch
sSearch_0
sSearch_1
sSearch_2
sSortDir_0	asc
*/
import org.apache.log4j.Logger;
logger = Logger.getLogger("test");

//
//EntityFacadeImpl efi = ec.ecfi.getEntityFacade();
//EntityFindImpl ef = new EntityFindImpl(efi, context.entity);
//
//def sd = sri.getActiveScreenDef();
//
//
//def parameters = ec.web.parameters;
//def sSortDir_0 = parameters.get('sSortDir_0');
//def mDataProp_0 = parameters.get('mDataProp_0');
//if (sSortDir_0 == 'asc'){
//	ef.orderBy("+" + mDataProp_0);
//}
//if (sSortDir_0 == 'desc'){
//	ef.orderBy("-" + mDataProp_0);
//}
//def iDisplayLength = parameters.get("iDisplayLength");
//if (iDisplayLength){
//	ef.limit(iDisplayLength.toInteger());
//}
//def iDisplayStart = parameters.get("iDisplayStart");
//if (iDisplayStart){
//	ef.offset(iDisplayStart.toInteger());
//}
//
//
//def dataList = ef.list();
//def dataCount = ef.count();
//
//
//def sEcho = parameters.get('sEcho') ?:1;
//def result = [sEcho:sEcho, iTotalRecords:dataCount, iTotalDisplayRecords:dataCount, aaData:dataList];
////result.put("a", "a");
//logger.info("==================================: ${sd}")
//ec.web.sendJsonResponse(result)

logger.info("==================================: respondDataTable.groovy exced!" + context.entity)

//context.result和return两者都可
context.result = ["result": "result hello zx."]
//return "bbb reslut"