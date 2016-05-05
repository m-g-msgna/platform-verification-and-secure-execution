/*!
    \file        functions.c
    \brief       Functions provided by the OS
    \version     1.0

*/

#include "functions.h"
#include "AES.h"

void WriteinIntE2prom(unsigned int dst, unsigned char *src, unsigned int len);
void ReadfromIntE2prom(unsigned int src, unsigned char *dst, unsigned int len);

/* global vars */
static unsigned char response[16];  /* 128 bits of input    */
static unsigned char key[176];      /* 176 bytes of round keys */
static unsigned char memory[500];   /* 5002 bytes of free memory      */
static unsigned char zdata[4];

static unsigned char result[1];

/*
**  do_AES_encrypt performs AES encryption on an 16 byte input block
*/
void do_AES_encrypt (command_APDU * com_APDU, response_APDU * resp_APDU)
{
  unsigned char ind, answerLength; 

  if ((*com_APDU).LC != 0x10) {  
   
    (*resp_APDU).LEN = 2;   
    (*resp_APDU).LE = 0;    
    (*resp_APDU).SW1 = 0x64;  
    (*resp_APDU).SW2 = 0x00;
    return;
  }
  
  for (ind = 0; ind < 16; ind++) {
    response[ind] = (*com_APDU).data_field[ind];
  }
  
  AES_enc (response, key, memory);

  
  for (ind = 0; ind < 16; ind++) {
    (*resp_APDU).data_field[ind] = response[ind];
  }
 
  if ((*com_APDU).LE <= 0x10) {
    answerLength = (*com_APDU).LE;
  }
  else {
    answerLength = 0x10;    
  }

  // send Ack
  (*resp_APDU).LEN = answerLength + 2;  
  (*resp_APDU).LE = answerLength;  
  (*resp_APDU).SW1 = 0x90;    
  (*resp_APDU).SW2 = 0x00;

}


/*
**  do_AES_decrypt performs AES encryption on an 16 byte input block
*/
void do_AES_decrypt (command_APDU * com_APDU, response_APDU * resp_APDU)
{
 
  unsigned char ind, answerLength;  

  if ((*com_APDU).LC != 0x10) { 
    
    (*resp_APDU).LEN = 2;  
    (*resp_APDU).LE = 0;   
    (*resp_APDU).SW1 = 0x64;
    (*resp_APDU).SW2 = 0x00;
    return;
  }

  for (ind = 0; ind < 16; ind++) {
    response[ind] = (*com_APDU).data_field[ind];
  }

  AES_dec (response, key, memory);

  for (ind = 0; ind < 16; ind++) {
    (*resp_APDU).data_field[ind] = response[ind];
  }
 
  if ((*com_APDU).LE <= 0x10) {
    answerLength = (*com_APDU).LE;
  }
  else {
    answerLength = 0x10;    
  }

  // send Ack
  (*resp_APDU).LEN = answerLength + 2;  
  (*resp_APDU).LE = answerLength;  
  (*resp_APDU).SW1 = 0x90;  
  (*resp_APDU).SW2 = 0x00;

}

/*
** do_set_key sets key to the transmitted value
*/
void do_set_key (command_APDU * com_APDU, response_APDU * resp_APDU)
{
  unsigned char ind;      

  if ((*com_APDU).LC != 0x10) {  
    
    (*resp_APDU).LEN = 2;    
    (*resp_APDU).LE = 0;    
    (*resp_APDU).SW1 = 0x64;  
    (*resp_APDU).SW2 = 0x00;
    return;
  }
 
  for (ind = 0; ind < 16; ind++) {
    response[ind] = (*com_APDU).data_field[ind];
  }

  schedule_key (response, key, memory);

  WriteinIntE2prom(0, key, 176);

  (*resp_APDU).LEN = 2;
  (*resp_APDU).LE = 0;    
  (*resp_APDU).SW1 = 0x90; 
  (*resp_APDU).SW2 = 0x00;
}

/*
** read_key_values from Internal E2prom
*/
void read_key_values (command_APDU * com_APDU, response_APDU * resp_APDU)
{
  if ((*com_APDU).LC != 0x0) {  

     //Wrong length, send error code 
    (*resp_APDU).LEN = 2;    
    (*resp_APDU).LE = 0;    
    (*resp_APDU).SW1 = 0x64;  
    (*resp_APDU).SW2 = 0x00;
    return;
  }

  ReadfromIntE2prom(0, key, 176);

  (*resp_APDU).LEN = 2;
  (*resp_APDU).LE = 0;  
  (*resp_APDU).SW1 = 0x90;  
  (*resp_APDU).SW2 = 0x00;
}

/*
** Main command Handler processing incoming APDUs
*/
void command_Handler (command_APDU * com_APDU, response_APDU * resp_APDU)
{
  (*resp_APDU).NAD = (*com_APDU).NAD;
  (*resp_APDU).PCB = (*com_APDU).PCB;

  if ((*com_APDU).PCB == 0xC1) {  /* S-Block Handling */

    (*resp_APDU).NAD = (*com_APDU).NAD;
    (*resp_APDU).PCB = 0xE1;
    (*resp_APDU).LEN = 1;
    (*resp_APDU).data_field[0] = (*com_APDU).CLA;
  }
  else {            /* I-Block Handling */

  switch ((*com_APDU).CLA) {
    case 0x80: {
      switch ((*com_APDU).INS) {		
        case 0x02:
			do_set_key (com_APDU, resp_APDU);
			break;
        case 0x03:
			read_key_values (com_APDU, resp_APDU);
			break;
        case 0x40:
			do_AES_encrypt (com_APDU, resp_APDU);
			break;
        case 0x42:
			do_AES_decrypt (com_APDU, resp_APDU);
			break;
        default:
          (*resp_APDU).LEN = 2;
          (*resp_APDU).LE = 0;
          (*resp_APDU).SW1 = 0x68;  //instruction not supported 
          (*resp_APDU).SW2 = 0x00;
          break;
        }
      break;
	  }
    default:
      {
      (*resp_APDU).LEN = 2;
      (*resp_APDU).LE = 0;
      (*resp_APDU).SW1 = 0x6e;  /* class not supported */
      (*resp_APDU).SW2 = 0x00;
      break;
      }
    }
  }
}
