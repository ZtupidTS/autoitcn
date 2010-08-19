#include "_XMLDomWrapper.au3"


_XMLFileOpen("test.xml")
;~ _XMLCreateChildWAttr("root/child/testChild[@name='test child 1' and @instance='1']", "ffffffffffffff", "ff", "fff")
;~ MsgBox(0, "", "")
;~ _XMLCreateChildWAttr("root/child/testChild[@name='test child 1' and @instance='2']", "ffffffffffffff", "ff", "fff")

_XMLSetAttrib("root/child/testChild[@name='test child 1' and @instance='2']", "name", "modified")
