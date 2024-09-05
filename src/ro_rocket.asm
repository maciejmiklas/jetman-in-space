;----------------------------------------------------------;
;               Building and Flying the Rocket             ;
;----------------------------------------------------------;
	MODULE ro

; Number of Counter40 cycles to drop next rocket module
DROP_NEXT_MAX				= 10
nextCnt						BYTE 0

; The state is used to build the rocket and then bring fuel to it. Building the rocket requires three elements, as does fueling it. 
; It's basically the same process, but Jetman is carrying either rocket elements or fuel tanks. Bit 7 determines whether Jetman is building 
; the rocket or already carries fuel. 
; Bits:
;  - 1-0: Current rocket element (or fuel tank), values 1-3
;  - 2  : Rocket element (or fuel tank) is falling down
;  - 3  : Rocket element (or fuel tank) is waiting for pickup
;  - 4  : Jetman carries rocket element (or fuel tank)
;  - 5  : Not used
;  - 6  : The rocket is fully assembled and waiting for fuel, or it is already fully tanked and waiting to start
;  - 7  : 1 - building rocket, 0 - bringing fuel
state						BYTE %00000001		; Start with building first rocket element

STATE_DROP_NEXT_MASK		= %00'111'0'1'0		; Dorp next element if the rocket is not fully assembled and no element is deployed at the moment
STATE_ELEMET_CNT_MASK		= %000000'11		; Reset all bits except the counter
STATE_ELEMET_CNT_MAX		= 3

; X coordinate to drop rocket element.
dropLocation
	DB 50, 70, 120

; Y coordinate where the dropped rocket element should land
landLocation
	DB 89, 225, 137

;----------------------------------------------------------;
;               #DropNextRocketElement                     ;
;----------------------------------------------------------;
DropNextRocketElement
	LD A, (state)
	AND STATE_DROP_NEXT_MASK					; Apply a mask to reset all bits, but only those indicating the rocket is ready or the element is deployed
	CP 0
	RET NZ

	; Increment the counter
	LD A, (nextCnt)
	INC A
	LD (nextCnt), A
	CP DROP_NEXT_MAX
	RET NZ										; Jump if #nextCnt !=  #DROP_NEXT_MAX 

	; The counter has reached the required value, reset it first
	LD A, 0
	LD (nextCnt), A

	; Check whether element counter has already reached max value
	LD A, (state)
	AND STATE_ELEMET_CNT_MASK
	CP STATE_ELEMET_CNT_MAX
	xxxxxxx
	RET	
;----------------------------------------------------------;
;                       ENDMODULE                          ;
;----------------------------------------------------------;
	ENDMODULE