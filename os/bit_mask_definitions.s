; v7.0
; Changelog:
; - Add system mode bm
; - Added BM_debounce_register_press & unpress. These are for the values to check our shifting byte-buffers, 
;       to see if we consider a button pressed or unpressed. 

BM_LED_Enable EQU &10 ; Bit for enabling/disabling LEDs on board
BM_Status EQU &80     ; Status, bit 7, of port A
BM_R_NOTW EQU &4      ; R/-W of port B
BM_RS EQU &2          ; RS of port B
BM_Enable_Interface EQU &1 ; Enable bit of port B
BM_button_upper EQU &40 ; Upper button enable bit of port B
BM_button_lower EQU &80 ; Lower button enable bit of port B

BM_system_mode EQU &1F
BM_interrupt_mode EQU &12
BM_BIC_for_usr_mode EQU &4

BM_set_output_kb_matrix_wires EQU &F0
BM_isolate_key_value EQU &F0
BM_kb_enable_1_4_7_ASTERISK EQU &80
BM_kb_enable_2_5_8_0 EQU &40
BM_kb_enable_3_6_9_HASH EQU &20

BM_KB_top_row_pressed EQU &1
BM_KB_bottom_row_pressed EQU &8

BM_debounce_register_press EQU &FF
BM_debounce_register_unpress EQU &00