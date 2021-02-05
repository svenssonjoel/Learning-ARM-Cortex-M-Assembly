
_estack = 0x20020000;

MEMORY
{
RAM (xrw)   : ORIGIN = 0x20000000, LENGTH = 128K
CCRAM (xrw) : ORIGIN = 0x10000000, LENGTH = 64K
FLASH (rx)  : ORIGIN = 0x08000000, LENGTH = 1024K
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
