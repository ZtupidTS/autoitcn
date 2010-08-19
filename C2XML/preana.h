typedef unsigned char   BYTE;

#define				PPLAT_SIP_TIMERTYPE_MAX		                    	50
#define			 PPLAT_SIP_METHOD_MAX              16

typedef struct 
{
    BYTE bAddrFamily; 
    BYTE bReserve[PPLAT_SIP_TIMERTYPE_MAX_];  
    BYTE   wPort;     
}T_IPADDR;

typedef struct {
    BYTE   wPort;     
	T_IPADDR addr[PPLAT_SIP_METHOD_MAX];
} ACK;