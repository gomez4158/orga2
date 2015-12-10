/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================

    Definiciones globales del sistema.
*/

#ifndef __DEFINES_H__
#define __DEFINES_H__

/* Bool */
/* -------------------------------------------------------------------------- */
#define TRUE                    0x00000001
#define FALSE                   0x00000000
#define ERROR                   1


/* Misc */
/* -------------------------------------------------------------------------- */
#define CANT_ZOMBIS             8

#define SIZE_W                  78
#define SIZE_H                  44


/* Indices en la gdt */
/* -------------------------------------------------------------------------- */
#define GDT_COUNT 31

#define GDT_IDX_NULL_DESC           0 
#define GDT_IDX_NULL_DESC_1           1
#define GDT_IDX_NULL_DESC_2           2
#define GDT_IDX_NULL_DESC_3           3
#define GDT_IDX_NULL_DESC_4           4
#define GDT_IDX_NULL_DESC_5           5
#define GDT_IDX_NULL_DESC_6           6
#define GDT_IDX_NULL_DESC_7           7
#define GDT_IDX_CODE_0           8
#define GDT_IDX_CODE_3           9
#define GDT_IDX_DATA_0           10
#define GDT_IDX_DATA_3           11
#define GDT_IDX_VIDEO            12
#define GDT_IDX_INICIAL			13
#define GDT_IDX_IDLE			14
#define GDT_IDX_TSS_A0			15
#define GDT_IDX_TSS_A1			16
#define GDT_IDX_TSS_A2			17
#define GDT_IDX_TSS_A3			18
#define GDT_IDX_TSS_A4			19
#define GDT_IDX_TSS_A5			20
#define GDT_IDX_TSS_A6			21
#define GDT_IDX_TSS_A7			22
#define GDT_IDX_TSS_B0			23
#define GDT_IDX_TSS_B1			24
#define GDT_IDX_TSS_B2			25
#define GDT_IDX_TSS_B3			26
#define GDT_IDX_TSS_B4			27
#define GDT_IDX_TSS_B5			28
#define GDT_IDX_TSS_B6			29
#define GDT_IDX_TSS_B7			30



/* Offsets en la gdt */
/* -------------------------------------------------------------------------- */
#define GDT_OFF_NULL_DESC           (GDT_IDX_NULL_DESC      << 3)
#define GDT_OFF_NULL_DESC_1   		(GDT_IDX_NULL_DESC_1      << 3) 
#define GDT_OFF_NULL_DESC_2         (GDT_IDX_NULL_DESC_2      << 3)
#define GDT_OFF_NULL_DESC_3         (GDT_IDX_NULL_DESC_3      << 3)
#define GDT_OFF_NULL_DESC_4         (GDT_IDX_NULL_DESC_4      << 3)
#define GDT_OFF_NULL_DESC_5         (GDT_IDX_NULL_DESC_5      << 3)
#define GDT_OFF_NULL_DESC_6         (GDT_IDX_NULL_DESC_6      << 3)
#define GDT_OFF_NULL_DESC_7         (GDT_IDX_NULL_DESC_7      << 3)
#define GDT_OFF_CODE_0              (GDT_IDX_CODE_0           << 3)
#define GDT_OFF_CODE_3              (GDT_IDX_CODE_3           << 3)
#define GDT_OFF_DATA_0              (GDT_IDX_DATA_0           << 3)
#define GDT_OFF_DATA_3              (GDT_IDX_DATA_3           << 3)
#define GDT_OFF_VIDEO               (GDT_IDX_VIDEO            << 3)
#define GDT_OFF_INICIAL             (GDT_IDX_INICIAL            << 3)
#define GDT_OFF_IDLE                (GDT_IDX_IDLE            << 3)
#define GDT_IDX_OFF_A0                (GDT_IDX_TSS_A0            << 3)
#define GDT_IDX_OFF_B0                (GDT_IDX_TSS_B0            << 3)
                                
/* Direcciones de memoria */
/* -------------------------------------------------------------------------- */
#define VIDEO                   0x000B8000 /* direccion fisica del buffer de video */

/* mmu */
/*------------------------------ */
#define area_libre 0x100000


#endif  /* !__DEFINES_H__ */



