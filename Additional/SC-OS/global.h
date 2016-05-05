/******************************************************/
/*! 
    \file        global.h
    \brief       globally defined vars and functions of the OS
    \version     1.0

*/
/*******************************************************/

#ifndef _Global
#define _Global

/* TRUE / FALSE / NULL */
#ifndef TRUE
#define TRUE            1
#endif

#ifndef FALSE
#define FALSE           0
#endif

#ifndef NULL
#define NULL            0
#endif

/* Return codes */
#define OK            1
#define ERROR        -1

/*Maximmum Bytes reserved in the input Buffer */
#define INPUT_BUFFER_SIZE 70

/* Definition of APDUs */
typedef struct
{
  unsigned char NAD;
  unsigned char PCB;
  unsigned char LEN;
  unsigned char CLA;
  unsigned char INS;
  unsigned char P1;
  unsigned char P2;
  unsigned char LC;
  unsigned char LE;
  unsigned char data_field[INPUT_BUFFER_SIZE - 9];

}
command_APDU;

typedef struct
{
  unsigned char NAD;
  unsigned char PCB;
  unsigned char LEN;
  unsigned char SW1;
  unsigned char SW2;
  unsigned char LE;
  unsigned char data_field[32];

}
response_APDU;

#endif
