
/*  SS_DBA_GRP defines the UNIX group ID for sqldba adminstrative access.  */
/*  Refer to the Installation and User's Guide for further information.  */

/* IMPORTANT: this file needs to be in sync with
              rdbms/src/server/osds/config.c, specifically regarding the
              number of elements in the ss_dba_grp array.
 */

#if 0
/*
 * Linux x86_64 assembly code corresponding to C code below. This module
 * can be compiled both as C and ASM module, when changing code here
 * please keep both versions in sync.
 */

        .section .rodata.str1.4, "aMS",@progbits,1
        .align 4
.Ldba_string:     .string "osdba"
.Loper_string:    .string "osoper"
.Lasm_string:     .string ""
.Lbkp_string:     .string "osbackupdba"
.Ldgd_string:     .string "osdgdba"
.Lkmt_string:     .string "oskmdba"
.Lrac_string:     .string "osracdba"

        .section        .rodata
        .align 8
        .globl ss_dba_grp
ss_dba_grp:
        .quad   .Ldba_string
        .quad   .Loper_string
        .quad   .Lasm_string
        .quad   .Lbkp_string
        .quad   .Ldgd_string
        .quad   .Lkmt_string
        .quad   .Lrac_string
        .type   ss_dba_grp,@object
        .size   ss_dba_grp,.-ss_dba_grp
        .section .note.GNU-stack, ""
        .end
/*
 * Assembler will not parse a file past the .end directive
 */
#endif

#define SS_DBA_GRP "osdba"
#define SS_OPER_GRP "osoper"
#define SS_ASM_GRP ""
#define SS_BKP_GRP "osbackupdba"
#define SS_DGD_GRP "osdgdba"
#define SS_KMT_GRP "oskmdba"
#define SS_RAC_GRP "osracdba"

const char * const ss_dba_grp[] = 
     {SS_DBA_GRP, SS_OPER_GRP, SS_ASM_GRP,
      SS_BKP_GRP, SS_DGD_GRP, SS_KMT_GRP,
      SS_RAC_GRP};   

