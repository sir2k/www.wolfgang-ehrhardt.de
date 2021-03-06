unit SC_INTF;

(*************************************************************************

 DESCRIPTION     :  Interface unit for SC_DLL

 REQUIREMENTS    :  D2-D7/D9-D10/D12, FPC

 EXTERNAL DATA   :  ---

 MEMORY USAGE    :  ---

 DISPLAY MODE    :  ---

 Version  Date      Author      Modification
 -------  --------  -------     ------------------------------------------
 0.10     02.01.05  W.Ehrhardt  Initial version a la BF_INTF
 0.11     16.07.09  we          SC_DLL_Version returns PAnsiChar, external 'SC_DLL.DLL'
 0.12     06.08.10  we          Longint ILen, SC_CTR_Seek/64 via sc_seek.inc
**************************************************************************)

(*-------------------------------------------------------------------------
 (C) Copyright 2005-2010 Wolfgang Ehrhardt

 This software is provided 'as-is', without any express or implied warranty.
 In no event will the authors be held liable for any damages arising from
 the use of this software.

 Permission is granted to anyone to use this software for any purpose,
 including commercial applications, and to alter it and redistribute it
 freely, subject to the following restrictions:

 1. The origin of this software must not be misrepresented; you must not
    claim that you wrote the original software. If you use this software in
    a product, an acknowledgment in the product documentation would be
    appreciated but is not required.

 2. Altered source versions must be plainly marked as such, and must not be
    misrepresented as being the original software.

 3. This notice may not be removed or altered from any source distribution.
----------------------------------------------------------------------------*)

{$i std.inc}

interface


const
  SC_Err_Invalid_Key_Size       = -1;  {Key size in bytes <1 or >64}
  SC_Err_Invalid_Length         = -3;  {No full block for cipher stealing}
  SC_Err_Data_After_Short_Block = -4;  {Short block must be last}
  SC_Err_MultipleIncProcs       = -5;  {More than one IncProc Setting}
  SC_Err_NIL_Pointer            = -6;  {nil pointer to block with nonzero length}

  SC_Err_CTR_SeekOffset         = -15; {Negative offset in SC_CTR_Seek}
  SC_Err_Invalid_16Bit_Length   = -20; {Pointer + Offset > $FFFF for 16 bit code}

type
  TSCKeyArr  = packed array[0..63] of longint;
  TSCBlock   = packed array[0..31] of byte;
  TWA8       = packed array[0..7]  of longint;
  PSCBlock   = ^TSCBlock;

type
  TSCIncProc = procedure(var CTR: TSCBlock);   {user supplied IncCTR proc}
                {$ifdef UseDLL} stdcall; {$endif}
type
  TSCContext = packed record
                 RK      : TSCKeyArr;  {round key array        }
                 IV      : TSCBlock;   {IV or CTR              }
                 buf     : TSCBlock;   {Work buffer            }
                 bLen    : word;       {Bytes used in buf      }
                 Flag    : word;       {Bit 1: Short block     }
                 IncProc : TSCIncProc; {Increment proc CTR-Mode}
               end;

const
  SCBLKSIZE  = sizeof(TSCBlock);



function  SC_DLL_Version: PAnsiChar;
stdcall; external 'SC_DLL.DLL' name 'SC_DLL_Version';
  {-Return DLL version as PAnsiChar}



function  SC_Init(const Key; KeyBytes: word; var ctx: TSCContext): integer;
stdcall; external 'SC_DLL.DLL' name 'SC_Init';
  {-SHACAL-2 context SBox initialization}

procedure SC_Encrypt(var ctx: TSCContext; const BI: TSCBlock; var BO: TSCBlock);
stdcall; external 'SC_DLL.DLL' name 'SC_Encrypt';
  {-encrypt one block (in ECB mode)}

procedure SC_Decrypt(var ctx: TSCContext; const BI: TSCBlock; var BO: TSCBlock);
stdcall; external 'SC_DLL.DLL' name 'SC_Decrypt';
  {-decrypt one block (in ECB mode)}

procedure SC_XorBlock(const B1, B2: TSCBlock; var B3: TSCBlock);
stdcall; external 'SC_DLL.DLL' name 'SC_XorBlock';
  {-xor two blocks, result in third}

procedure SC_SetFastInit(value: boolean);
stdcall; external 'SC_DLL.DLL' name 'SC_SetFastInit';
  {-set FastInit variable}

function  SC_GetFastInit: boolean;
stdcall; external 'SC_DLL.DLL' name 'SC_GetFastInit';
  {-Returns FastInit variable}



function  SC_CBC_Init(const Key; KeyBytes: word; const IV: TSCBlock; var ctx: TSCContext): integer;
stdcall; external 'SC_DLL.DLL' name 'SC_CBC_Init';
  {-SHACAL-2 key expansion, error if invalid key size, save IV}

procedure SC_CBC_Reset(const IV: TSCBlock; var ctx: TSCContext);
stdcall; external 'SC_DLL.DLL' name 'SC_CBC_Reset';
  {-Clears ctx fields bLen and Flag, save IV}

function  SC_CBC_Encrypt(ptp, ctp: Pointer; ILen: longint; var ctx: TSCContext): integer;
stdcall; external 'SC_DLL.DLL' name 'SC_CBC_Encrypt';
  {-Encrypt ILen bytes from ptp^ to ctp^ in CBC mode}

function  SC_CBC_Decrypt(ctp, ptp: Pointer; ILen: longint; var ctx: TSCContext): integer;
stdcall; external 'SC_DLL.DLL' name 'SC_CBC_Decrypt';
  {-Decrypt ILen bytes from ctp^ to ptp^ in CBC mode}



function  SC_CFB_Init(const Key; KeyBytes: word; const IV: TSCBlock; var ctx: TSCContext): integer;
stdcall; external 'SC_DLL.DLL' name 'SC_CFB_Init';
  {-SHACAL-2 key expansion, error if invalid key size, encrypt IV}

procedure SC_CFB_Reset(const IV: TSCBlock; var ctx: TSCContext);
stdcall; external 'SC_DLL.DLL' name 'SC_CFB_Reset';
  {-Clears ctx fields bLen and Flag, encrypt IV}

function  SC_CFB_Encrypt(ptp, ctp: Pointer; ILen: longint; var ctx: TSCContext): integer;
stdcall; external 'SC_DLL.DLL' name 'SC_CFB_Encrypt';
  {-Encrypt ILen bytes from ptp^ to ctp^ in CFB mode}

function  SC_CFB_Decrypt(ctp, ptp: Pointer; ILen: longint; var ctx: TSCContext): integer;
stdcall; external 'SC_DLL.DLL' name 'SC_CFB_Decrypt';
  {-Decrypt ILen bytes from ctp^ to ptp^ in CFB mode}



function  SC_CTR_Init(const Key; KeyBytes: word; const CTR: TSCBlock; var ctx: TSCContext): integer;
stdcall; external 'SC_DLL.DLL' name 'SC_CTR_Init';
  {-SHACAL-2 key expansion, error if inv. key size, encrypt CTR}

procedure SC_CTR_Reset(const CTR: TSCBlock; var ctx: TSCContext);
stdcall; external 'SC_DLL.DLL' name 'SC_CTR_Reset';
  {-Clears ctx fields bLen and Flag, encrypt CTR}

function  SC_CTR_Encrypt(ptp, ctp: Pointer; ILen: longint; var ctx: TSCContext): integer;
stdcall; external 'SC_DLL.DLL' name 'SC_CTR_Encrypt';
  {-Encrypt ILen bytes from ptp^ to ctp^ in CTR mode}

function  SC_CTR_Decrypt(ctp, ptp: Pointer; ILen: longint; var ctx: TSCContext): integer;
stdcall; external 'SC_DLL.DLL' name 'SC_CTR_Decrypt';
  {-Decrypt ILen bytes from ctp^ to ptp^ in CTR mode}

function  SC_CTR_Seek(const iCTR: TSCBlock; SOL, SOH: longint; var ctx: TSCContext): integer;
  {-Setup ctx for random access crypto stream starting at 64 bit offset SOH*2^32+SOL,}
  { SOH >= 0. iCTR is the initial CTR for offset 0, i.e. the same as in SC_CTR_Init.}

{$ifdef HAS_INT64}
function SC_CTR_Seek64(const iCTR: TSCBlock; SO: int64; var ctx: TSCContext): integer;
  {-Setup ctx for random access crypto stream starting at 64 bit offset SO >= 0;}
  { iCTR is the initial CTR value for offset 0, i.e. the same as in SC_CTR_Init.}
{$endif}

function  SC_SetIncProc(IncP: TSCIncProc; var ctx: TSCContext): integer;
stdcall; external 'SC_DLL.DLL' name 'SC_SetIncProc';
  {-Set user supplied IncCTR proc}

procedure SC_IncMSBFull(var CTR: TSCBlock);
stdcall; external 'SC_DLL.DLL' name 'SC_IncMSBFull';
  {-Increment CTR[31]..CTR[0]}

procedure SC_IncLSBFull(var CTR: TSCBlock);
stdcall; external 'SC_DLL.DLL' name 'SC_IncLSBFull';
  {-Increment CTR[0]..CTR[31]}

procedure SC_IncMSBPart(var CTR: TSCBlock);
stdcall; external 'SC_DLL.DLL' name 'SC_IncMSBPart';
  {-Increment CTR[31]..CTR[16]}

procedure SC_IncLSBPart(var CTR: TSCBlock);
stdcall; external 'SC_DLL.DLL' name 'SC_IncLSBPart';
  {-Increment CTR[0]..CTR[15]}



function  SC_ECB_Init(const Key; KeyBytes: word; var ctx: TSCContext): integer;
stdcall; external 'SC_DLL.DLL' name 'SC_ECB_Init';
  {-SHACAL-2 key expansion, error if invalid key size}

procedure SC_ECB_Reset(var ctx: TSCContext);
stdcall; external 'SC_DLL.DLL' name 'SC_ECB_Reset';
  {-Clears ctx fields bLen and Flag}

function  SC_ECB_Encrypt(ptp, ctp: Pointer; ILen: longint; var ctx: TSCContext): integer;
stdcall; external 'SC_DLL.DLL' name 'SC_ECB_Encrypt';
  {-Encrypt ILen bytes from ptp^ to ctp^ in ECB mode}

function  SC_ECB_Decrypt(ctp, ptp: Pointer; ILen: longint; var ctx: TSCContext): integer;
stdcall; external 'SC_DLL.DLL' name 'SC_ECB_Decrypt';
  {-Decrypt ILen bytes from ctp^ to ptp^ in ECB mode}



function  SC_OFB_Init(const Key; KeyBits: word; const IV: TSCBlock; var ctx: TSCContext): integer;
stdcall; external 'SC_DLL.DLL' name 'SC_OFB_Init';
  {-SHACAL-2 key expansion, error if invalid key size, encrypt IV}

procedure SC_OFB_Reset(const IV: TSCBlock; var ctx: TSCContext);
stdcall; external 'SC_DLL.DLL' name 'SC_OFB_Reset';
  {-Clears ctx fields bLen and Flag, encrypt IV}

function  SC_OFB_Encrypt(ptp, ctp: Pointer; ILen: longint; var ctx: TSCContext): integer;
stdcall; external 'SC_DLL.DLL' name 'SC_OFB_Encrypt';
  {-Encrypt ILen bytes from ptp^ to ctp^ in OFB mode}

function  SC_OFB_Decrypt(ctp, ptp: Pointer; ILen: longint; var ctx: TSCContext): integer;
stdcall; external 'SC_DLL.DLL' name 'SC_OFB_Decrypt';
  {-Decrypt ILen bytes from ctp^ to ptp^ in OFB mode}


implementation

{$i sc_seek.inc}
end.
