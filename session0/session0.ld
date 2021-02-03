

_estack = 0x20010000;

MEMORY
{
FLASH (rx)  : ORIGIN = 0x08000000, LENGTH = 1024K
CCRAM (xrw) : ORIGIN = 0x10000000, LENGTH = 64K
RAM (xrw)   : ORIGIN = 0x20000000, LENGTH = 128K
}


SECTIONS
{

.text : {	
      *(.text)
}>FLASH

_flash_dstart = .;

.data :  {
      _dstart = .;
      *(.data)
      _dend = .; 
}>RAM AT> FLASH  /* Load into FLASH, but live in RAM */






} /* SECTIONS END */ 
