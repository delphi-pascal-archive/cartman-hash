 (**      HasCart.Pas by Alexander Myasnikov                        **)
 (**      HashCart Hash function  based on Cartman block cipher     **)
 (**      Freeware for any use,  non-patented, opensource cipher    **)
 (**      WEB:       www.darksoftware.narod.ru                      **)
 (**      Cartman block cipher project information                  **)
 (**      WEB:       www.alexanderwdark.narod.ru                    **)


unit hashcart;


interface


type
  THashCart = class(TObject)

  public
    procedure update (Data: pointer; len: integer);
    procedure final (digest: pointer);
    procedure burn;

    constructor Create (mix: integer = 5);
  private
    keystream:  array [0..3] of longword;
    mix_cycles: integer;
  end;

var
  HCart: THashCart = nil;

implementation

uses hccartman, Windows;

const
  H_Data: array[0..15] of longword =
    ($452821E6, $38D01377, $BE5466CF, $34E90C6C, $C0AC29B7, $C97C50DD,
    $3F84D5B5, $B5470917,
    $9216D5D9, $8979FB1B, $D1310BA6, $98DFB5AC, $2FFD72DB, $D01ADFB7,
    $B8E1AFED, $6A267E96);

const
  SBOX: array[0..4, 0..255] of byte = ((
    177, 206, 195, 149, 90, 173, 231, 2, 77, 68, 251, 145, 12, 135, 161, 80,
    203, 103, 84, 221, 70, 143, 225, 78, 240, 253, 252, 235, 249, 196, 26, 110,
    94, 245, 204, 141, 28, 86, 67, 254, 7, 97, 248, 117, 89, 255, 3, 34,
    138, 209, 19, 238, 136, 0, 14, 52, 21, 128, 148, 227, 237, 181, 83, 35,
    75, 71, 23, 167, 144, 53, 171, 216, 184, 223, 79, 87, 154, 146, 219, 27,
    60, 200, 153, 4, 142, 224, 215, 125, 133, 187, 64, 44, 58, 69, 241, 66,
    101, 32, 65, 24, 114, 37, 147, 112, 54, 5, 242, 11, 163, 121, 236, 8,
    39, 49, 50, 182, 124, 176, 10, 115, 91, 123, 183, 129, 210, 13, 106, 38,
    158, 88, 156, 131, 116, 179, 172, 48, 122, 105, 119, 15, 174, 33, 222, 208,
    46, 151, 16, 164, 152, 168, 212, 104, 45, 98, 41, 109, 22, 73, 118, 199,
    232, 193, 150, 55, 229, 202, 244, 233, 99, 18, 194, 166, 20, 188, 211, 40,
    175, 47, 230, 36, 82, 198, 160, 9, 189, 140, 207, 93, 17, 95, 1, 197,
    159, 61, 162, 155, 201, 59, 190, 81, 25, 31, 63, 92, 178, 239, 74, 205,
    191, 186, 111, 100, 217, 243, 62, 180, 170, 220, 213, 6, 192, 126, 246, 102,
    108, 132, 113, 56, 185, 29, 127, 157, 72, 139, 42, 218, 165, 51, 130, 57,
    214, 120, 134, 250, 228, 43, 169, 30, 137, 96, 107, 234, 85, 76, 247, 226),

    (
    53, 190, 7, 46, 83, 105, 219, 40, 111, 183, 118, 107, 12, 125, 54, 139,
    146, 188, 169, 50, 172, 56, 156, 66, 99, 200, 30, 79, 36, 229, 247, 201,
    97, 141, 47, 63, 179, 101, 127, 112, 175, 154, 234, 245, 91, 152, 144, 177,
    135, 113, 114, 237, 55, 69, 104, 163, 227, 239, 92, 197, 80, 193, 214, 202,
    90, 98, 95, 38, 9, 93, 20, 65, 232, 157, 206, 64, 253, 8, 23, 74,
    15, 199, 180, 62, 18, 252, 37, 75, 129, 44, 4, 120, 203, 187, 32, 189,
    249, 41, 153, 168, 211, 96, 223, 17, 151, 137, 126, 250, 224, 155, 31, 210,
    103, 226, 100, 119, 132, 43, 158, 138, 241, 109, 136, 121, 116, 87, 221, 230,
    57, 123, 238, 131, 225, 88, 242, 13, 52, 248, 48, 233, 185, 35, 84, 21,
    68, 11, 77, 102, 58, 3, 162, 145, 148, 82, 76, 195, 130, 231, 128, 192,
    182, 14, 194, 108, 147, 236, 171, 67, 149, 246, 216, 70, 134, 5, 140, 176,
    117, 0, 204, 133, 215, 61, 115, 122, 72, 228, 209, 89, 173, 184, 198, 208,
    220, 161, 170, 2, 29, 191, 181, 159, 81, 196, 165, 16, 34, 207, 1, 186,
    143, 49, 124, 174, 150, 218, 240, 86, 71, 212, 235, 78, 217, 19, 142, 73,
    85, 22, 255, 59, 244, 164, 178, 6, 160, 167, 251, 27, 110, 60, 51, 205,
    24, 94, 106, 213, 166, 33, 222, 254, 42, 28, 243, 10, 26, 25, 39, 45),

    (
    $A3, $D7, $09, $83, $F8, $48, $F6, $F4, $B3, $21, $15, $78, $99, $B1, $AF, $F9,
    $E7, $2D, $4D, $8A, $CE, $4C, $CA, $2E, $52, $95, $D9, $1E, $4E, $38, $44, $28,
    $0A, $DF, $02, $A0, $17, $F1, $60, $68, $12, $B7, $7A, $C3, $E9, $FA, $3D, $53,
    $96, $84, $6B, $BA, $F2, $63, $9A, $19, $7C, $AE, $E5, $F5, $F7, $16, $6A, $A2,
    $39, $B6, $7B, $0F, $C1, $93, $81, $1B, $EE, $B4, $1A, $EA, $D0, $91, $2F, $B8,
    $55, $B9, $DA, $85, $3F, $41, $BF, $E0, $5A, $58, $80, $5F, $66, $0B, $D8, $90,
    $35, $D5, $C0, $A7, $33, $06, $65, $69, $45, $00, $94, $56, $6D, $98, $9B, $76,
    $97, $FC, $B2, $C2, $B0, $FE, $DB, $20, $E1, $EB, $D6, $E4, $DD, $47, $4A, $1D,
    $42, $ED, $9E, $6E, $49, $3C, $CD, $43, $27, $D2, $07, $D4, $DE, $C7, $67, $18,
    $89, $CB, $30, $1F, $8D, $C6, $8F, $AA, $C8, $74, $DC, $C9, $5D, $5C, $31, $A4,
    $70, $88, $61, $2C, $9F, $0D, $2B, $87, $50, $82, $54, $64, $26, $7D, $03, $40,
    $34, $4B, $1C, $73, $D1, $C4, $FD, $3B, $CC, $FB, $7F, $AB, $E6, $3E, $5B, $A5,
    $AD, $04, $23, $9C, $14, $51, $22, $F0, $29, $79, $71, $7E, $FF, $8C, $0E, $E2,
    $0C, $EF, $BC, $72, $75, $6F, $37, $A1, $EC, $D3, $8E, $62, $8B, $86, $10, $E8,
    $08, $77, $11, $BE, $92, $4F, $24, $C5, $32, $36, $9D, $CF, $F3, $A6, $BB, $AC,
    $5E, $6C, $A9, $13, $57, $25, $B5, $E3, $BD, $A8, $3A, $01, $05, $59, $2A, $46),

    (
    32, 137, 239, 188, 102, 125, 221, 72, 212, 68, 81, 37, 86, 237, 147, 149,
    70, 229, 17, 124, 115, 207, 33, 20, 122, 143, 25, 215, 51, 183, 138, 142,
    146, 211, 110, 173, 1, 228, 189, 14, 103, 78, 162, 36, 253, 167, 116, 255,
    158, 45, 185, 50, 98, 168, 250, 235, 54, 141, 195, 247, 240, 63, 148, 2,
    224, 169, 214, 180, 62, 22, 117, 108, 19, 172, 161, 159, 160, 47, 43, 171,
    194, 175, 178, 56, 196, 112, 23, 220, 89, 21, 164, 130, 157, 8, 85, 251,
    216, 44, 94, 179, 226, 38, 90, 119, 40, 202, 34, 206, 35, 69, 231, 246,
    29, 109, 74, 71, 176, 6, 60, 145, 65, 13, 77, 151, 12, 127, 95, 199,
    57, 101, 5, 232, 150, 210, 129, 24, 181, 10, 121, 187, 48, 193, 139, 252,
    219, 64, 88, 233, 96, 128, 80, 53, 191, 144, 218, 11, 106, 132, 155, 104,
    91, 136, 31, 42, 243, 66, 126, 135, 30, 26, 87, 186, 182, 154, 242, 123,
    82, 166, 208, 39, 152, 190, 113, 205, 114, 105, 225, 84, 73, 163, 99, 111,
    204, 61, 200, 217, 170, 15, 198, 28, 192, 254, 134, 234, 222, 7, 236, 248,
    201, 41, 177, 156, 92, 131, 67, 249, 245, 184, 203, 9, 241, 0, 27, 46,
    133, 174, 75, 18, 93, 209, 100, 120, 76, 213, 16, 83, 4, 107, 140, 52,
    58, 55, 3, 244, 97, 197, 238, 227, 118, 49, 79, 230, 223, 165, 153, 59),

    (
    $63, $7C, $77, $7B, $F2, $6B, $6F, $C5, $30, $01, $67, $2B, $FE, $D7, $AB, $76,
    $CA, $82, $C9, $7D, $FA, $59, $47, $F0, $AD, $D4, $A2, $AF, $9C, $A4, $72, $C0,
    $B7, $FD, $93, $26, $36, $3F, $F7, $CC, $34, $A5, $E5, $F1, $71, $D8, $31, $15,
    $04, $C7, $23, $C3, $18, $96, $05, $9A, $07, $12, $80, $E2, $EB, $27, $B2, $75,
    $09, $83, $2C, $1A, $1B, $6E, $5A, $A0, $52, $3B, $D6, $B3, $29, $E3, $2F, $84,
    $53, $D1, $00, $ED, $20, $FC, $B1, $5B, $6A, $CB, $BE, $39, $4A, $4C, $58, $CF,
    $D0, $EF, $AA, $FB, $43, $4D, $33, $85, $45, $F9, $02, $7F, $50, $3C, $9F, $A8,
    $51, $A3, $40, $8F, $92, $9D, $38, $F5, $BC, $B6, $DA, $21, $10, $FF, $F3, $D2,
    $CD, $0C, $13, $EC, $5F, $97, $44, $17, $C4, $A7, $7E, $3D, $64, $5D, $19, $73,
    $60, $81, $4F, $DC, $22, $2A, $90, $88, $46, $EE, $B8, $14, $DE, $5E, $0B, $DB,
    $E0, $32, $3A, $0A, $49, $06, $24, $5C, $C2, $D3, $AC, $62, $91, $95, $E4, $79,
    $E7, $C8, $37, $6D, $8D, $D5, $4E, $A9, $6C, $56, $F4, $EA, $65, $7A, $AE, $08,
    $BA, $78, $25, $2E, $1C, $A6, $B4, $C6, $E8, $DD, $74, $1F, $4B, $BD, $8B, $8A,
    $70, $3E, $B5, $66, $48, $03, $F6, $0E, $61, $35, $57, $B9, $86, $C1, $1D, $9E,
    $E1, $F8, $98, $11, $69, $D9, $8E, $94, $9B, $1E, $87, $E9, $CE, $55, $28, $DF,
    $8C, $A1, $89, $0D, $BF, $E6, $42, $68, $41, $99, $2D, $0F, $B0, $54, $BB, $16));


type
  TLongWordArray = array [0.. 15] of longword;

type
  PLongWordArray = ^TLongWordArray;

type
  TByteArray = array [0.. 511] of byte;

type
  PByteArray = ^TByteArray;


constructor THashCart.Create (mix: integer = 5);
begin
  mix_cycles := mix;
end;

procedure THashCart.burn;
begin
  FillChar(Keystream, 16, 0);
end;

procedure THashCart.update (Data: Pointer; len: integer);
var
  InitArray: array [0..15] of longword;
  iv: array[0..3] of longword;
var
  i, n, max: integer;

begin

  for I := 0 to 15 do
    begin
    InitArray[i] := H_Data[i];
    end;

  if len >= 16 then
    max := 16
  else
    max := len;


  for I := 0 to max - 1 do
    begin

    PByteArray(@InitArray)^[i] := PByteArray(Data)^[i];

    end;


  hccartman_setkey(@InitArray[0]);
  Move(InitArray[12], KeyStream, 16);

  for I := 0 to 15 do
    PByteArray(@Keystream)^[i] := SBOX[0, PByteArray(@Keystream)^[i]];


  for I := 0 to mix_cycles - 1 do
    begin
    hccartman_decrypt(@KeyStream);

    for n := 0 to 15 do
      PByteArray(@Keystream)^[i] := SBOX[1, PByteArray(@Keystream)^[i]];

    end;


  Move(KeyStream, Iv, 16);

  if len >= 16 then
    begin

    repeat
      Move(Data^, KeyStream, 16);
      for I := 0 to 3 do
        KeyStream[i] := KeyStream[i] xor Iv[i];

      for I := 0 to 15 do
        PByteArray(@Keystream)^[i] := SBOX[2, PByteArray(@Keystream)^[i]];


      Dec(len, 16);
      longword(Data) := longword(Data) + 16;
      hccartman_crypt(@KeyStream);
      Move(KeyStream, Iv, 16);
    until len < 16;

    end;

  if len > 0 then
    begin
    Move(Data^, KeyStream, len);

    for I := 0 to 15 do
      PByteArray(@Keystream)^[i] := SBOX[3, PByteArray(@Keystream)^[i]];

    for I := 0 to 3 do
      KeyStream[i] := KeyStream[i] xor Iv[i];
    hccartman_crypt(@KeyStream);
    end;

  for I := 0 to 15 do
    begin
    PByteArray(@Keystream)^[i] := SBOX[4, PByteArray(@Keystream)^[i]];
    for n := 0 to mix_cycles - 1 do
      hccartman_crypt(@KeyStream);
    end;

end;


procedure THashCart.final (digest: Pointer);
begin
  Move(keystream, digest^, 16);
end;


initialization
  HCart := THashCart.Create;

finalization
  HCart.Free;

end.
