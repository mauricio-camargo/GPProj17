{
 I give this code to the public domain, so everyone can use it, 
 just like using your own code.
}

unit uHistory;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, StdCtrls, Forms, lazUTF8, ClipBrd;

type

  // 单步历史记录（Single history step）

  { TStep }

  TStep = class   
  
  private
  
    FPrev      : TStep;
    FNext      : TStep;

    // < 0 means user deleted text, > 0 means user added text, based on 1
    // 小于 0 表示删除文本，大于 0 表示添加文本，从 1 开始计数
    FSelStart  : SizeInt;
    FSelLength : SizeInt;
    FSelText   : String;

    // Mark whether the current history is a half step. For example, the drag  
    // operation inside TMemo is divided into two sub steps: add and delete
    // 标记当前历史记录是否为半个步骤，比如 TMemo 内部的拖拽操作会分成
    // “添加”和“删除”两个子步骤
    FHalf      : Integer;
  
  public
  
    constructor Create(SelStart: SizeInt; SelLength: SizeInt; SelText: String;
      Half: Integer = 0; Prev: TStep=nil; Next: TStep=nil);
    destructor  Destroy(); override;
  
  end;



  // 全部历史记录（all history steps）

  { TSteps }

  TSteps = class

  private

    FHead     : TStep;
    FCurrent  : TStep;

    FSize     : SizeInt;
    FMaxSize  : SizeInt;

    FIndex    : Integer;

    FCount    : Integer;
    FMinCount : Integer;

    FDelimiters    : set of Char;
    FMaxWordLen    : Integer;
    FNewStep       : Boolean;

    procedure Add(SelStart: SizeInt; SelLength: SizeInt; SelText: string; Half: Boolean);
    procedure Limit;

  public

    constructor Create(MaxSize: SizeInt=0; MinCount: Integer=0);
    destructor  Destroy; override;

    procedure Prev;
    procedure Next;
    procedure Reset;

    property  Size  : SizeInt read FSize;  
    property  Index : Integer read FIndex;
    property  Count : Integer read FCount;

  end;



  { THistory }

  THistory = class

  private

    FMemo               : TCustomMemo;
    FSteps              : TSteps;

    FOldOnChange        : TNotifyEvent;
    FOldApplicationIdle : TIdleEvent;

    FPrevContent        : String;
    // FPrevSelStart       : SizeInt;

    // Some user actions will trigger onchange events twice in a row. 
    // This flag is used to record whether the current onchange event 
    // is the second half of a continuous event.
    // 某些用户操作会连续触发两次 OnChange 事件，该标记用于记录当前
    //  OnChange 事件是否是连续事件中的后半部分。
    FHalf               : Boolean;

    // Whether it is in user edit mode or not. It is not in edit mode when 
    // undo or redo is executing, so the changes of TMemo will not be recorded
    // 是否处于用户编辑模式，在执行 Undo 或 Redo 时不处于编辑模式，不会记录 TMemo 的变动
    FInEdit             : Boolean;

    // Used to fix the bug that "OnChange event is not triggered when 
    // TMemo.SelText is modified" in some Lazarus versions 
    // 用于修复某些 Lazarus 版本中“修改了 TMemo.SelText 时不触发 OnChange 事件”的 Bug
    FixOnChangeBug      : Boolean;

    // Used to automatically select the undo or redo text after undo or redo
    // 用于在撤销或重做之后自动选中被撤销或重做的文本
    FAutoSelStart       : SizeInt;

    procedure MemoOnChange(Sender: TObject);
    procedure ApplicationIdle(Sender: TObject; var Done: Boolean);

    function  GetSize: SizeInt;
    function  GetIndex: Integer;
    function  GetCount: Integer;

  public

    constructor Create(Memo: TCustomMemo; Delimiters: String = ''; MaxWordLen: Integer = 32;
      MaxSize: SizeInt = 0; MinCount: Integer = 0);
    destructor  Destroy; override;

    function CanRedo: Boolean;
    function CanUndo: Boolean;

    procedure Undo(AutoSelect: Boolean = False);
    procedure Redo(AutoSelect: Boolean = False);

    procedure Reset;

    procedure PasteText;

    property Size : SizeInt read GetSize;
    property Index: Integer read GetIndex;
    property Count: Integer read GetCount;

  end;


implementation

{ TStep }

constructor TStep.Create(SelStart: SizeInt; SelLength: SizeInt; SelText: String;
  Half: Integer = 0; Prev: TStep = nil; Next: TStep = nil);
begin
  Self.FSelStart  := SelStart;
  Self.FSelLength := SelLength;
  Self.FSelText   := SelText;

  Self.FHalf      := Half;

  Self.FPrev      := Prev;
  Self.FNext      := Next;
end;


destructor TStep.Destroy();
begin                      
  if Self.FPrev <> nil then
    Self.FPrev.FNext := nil;

  if Self.FNext <> nil then
    Self.FNext.Free;
end;



constructor TSteps.Create(MaxSize: SizeInt = 0; MinCount: Integer = 0);
begin
  FHead     := TStep.Create(0, 0, '');
  FCurrent  := FHead;

  FSize     := 0;
  FMaxSize  := MaxSize;

  FIndex    := 0;

  FCount    := 0;
  FMinCount := MinCount;

  FDelimiters := [];
  FMaxWordLen := 1;
  FNewStep    := True;
end;


destructor TSteps.Destroy;
begin
  FHead.Free;
  inherited Destroy;
end;

                           
procedure TSteps.Prev;
begin
  if FCurrent <> FHead then
    FCurrent := FCurrent.FPrev;
  Dec(FIndex);
  FNewStep := True;
end;


procedure TSteps.Next;
begin
  if FCurrent.FNext <> nil then
    FCurrent := FCurrent.FNext;
  Inc(FIndex);      
  FNewStep := True;
end;


procedure TSteps.Reset;
begin
  if FHead.FNext <> nil then begin
    FHead.FNext.Free;
    FHead.FNext := nil;

    FCurrent := FHead;
                
    FSize  := 0;
    FIndex := 0;
    FCount := 0;

    FNewStep := True;
  end;
end;


procedure TSteps.Add(SelStart: SizeInt; SelLength: SizeInt; SelText: string; Half: Boolean);

  procedure DoAdd();
  begin
    // 移除后续的历史步骤（Remove subsequent history steps）
    if FCurrent.FNext <> nil then begin
      FCurrent.FNext.Free;
      FCount := FIndex;
    end;

    // 修正前一步历史记录（Revise previous history step）
    if Half and (FCurrent <> FHead) then
      FCurrent.FHalf := 1;  // 前半步（The first half step）

    // 添加当前历史步骤（Add current history step）
    FCurrent.FNext := TStep.Create(SelStart, SelLength, SelText, 0, FCurrent);
    FCurrent := FCurrent.FNext;

    if Half then
      FCurrent.FHalf := 2   // 后半步（The second half step）
    else
      FCurrent.FHalf := 0;  // 完整一步（a complete step）

    Inc(FSize, Sizeof(TStep) + Length(SelText));
    Inc(FIndex);
    Inc(FCount);

    Limit;

    FNewStep := False;
  end;

begin

  // add a new record (such as encountering a space) or merge the content
  // into the previous record
  // 是增加一条新记录（比如遇到空格）还是将内容并入到前一条记录中
  if (FDelimiters = []) or (Length(SelText) > 1) or
  FNewStep or (FCurrent.FSelLength >= FMaxWordLen) or
  (FCurrent.FSelStart > 0) and (SelStart < 0) or
  (FCurrent.FSelStart < 0) and (SelStart > 0) or
  (SelText[1] in FDelimiters) then
    DoAdd

  else begin
    Inc(FCurrent.FSelLength);
    if FCurrent.FSelStart < 0 then begin
      Inc(FCurrent.FSelStart);       
      FCurrent.FSelText := SelText + FCurrent.FSelText;
    end else begin              
      FCurrent.FSelText := FCurrent.FSelText + SelText;
    end;
  end;

end;


// Limit the size of history, but ensure that the number 
// of history is not less than MinCount
// 限制历史记录大小，但保证历史记录数量不低于 MinCount
procedure TSteps.Limit;
var
  First: TStep;
begin
  while (FMaxSize > 0) and (FSize > FMaxSize) and (FCount > FMinCount) do begin       
    First := FHead.FNext;
    FSize := FSize - Sizeof(TStep) - Length(First.FSelText);
    FHead.FNext := First.FNext;

    First.FNext := nil;
    First.Free;

    Dec(FIndex);
    Dec(FCount);
  end;
end;

// Convert the character index of UTF8 string to byte index, 
// return 0 if UPos <= 0, and return size+1 if UPos > size.
// This function does not check the integrity of utf8 encoding
// and does not support multi code point characters, which will
// be treated as multiple characters.

// 将 UTF8 字符串的字符索引转换为字节索引， 如果 UPos <= 0，则返回 0，
// 如果 UPos > Size，则返回 Size + 1。本函数不检查 UTF8 编码的完整性，
// 不支持多码点字符，多码点字符会被当成多个字符处理。

// Text         : UTF8 字符串（UTF8 string）
// Size         : UTF8 字符串的字节长度（Byte length of UTF8 string）
// UPos         : 字符索引，从 1 开始（Character index, based on 1）
// Return Value : The byte index corresponding to UPos, based on 1
// Return Value : UPos 对应的字节索引，从 1 开始
function UTF8PosToBytePos(const Text: PChar; const Size: SizeInt; UPos: SizeInt): SizeInt;
begin
  Result := 0;
  if UPos <= 0 then Exit;

  while (UPos > 1) and (Result < Size) do begin
    case Text[Result] of
      // #0  ..#127: Inc(Pos);
      #192..#223: Inc(Result, 2);
      #224..#239: Inc(Result, 3);
      #240..#247: Inc(Result, 4);
      else Inc(Result);
    end;
    Dec(UPos);
  end;

  Inc(Result);
end;

function UTF8PosToBytePos(const Text: String; const UPos: SizeInt): SizeInt; inline;
begin
  Result := UTF8PosToBytePos(PChar(Text), Length(Text), UPos);
end;



// Parameters:
// Memo is a TMemo control that is taken over and wants to
// implement the undoredo function
// Delimiters is a character sequence used to segment words.
// In the OnChange event, the history will be recorded only 
// when the specified character is encountered (in addition,
// when the length of the input data exceeds MaxWordLen, if
// the separator is not encountered, the history will also
// be recorded). If this parameter is empty, it means that
// the history will be recorded when any character is entered
// in TMemo.
// MaxSize is the maximum number of bytes of the total history
// allowed to be stored
// Mincount is the minimum number of history entries that must
// be kept (priority is higher than MaxSize)

// 参数：
// Memo 是被接管的希望实现 UndoRedo 功能的 TMemo 控件
// Delimiters 是用于分割单词的字符序列，在 OnChange 事件中，当遇到指定
// 的字符时，才会记录历史数据（另外，当输入的数据长度超过 MaxWordLen
// 时，如果仍没有遇到分隔符，也会记录历史数据），如果该参数为空，则表
// 示在 TMemo中输入任何一个字符时，都会记录历史数据。   
// MaxSize 是允许存储的总历史记录的最大字节数
// MinCount 是必须保留的最少的历史记录条目数（优先级高于 MaxSize）

constructor THistory.Create(Memo: TCustomMemo; Delimiters: String = '';
  MaxWordLen: Integer = 32; MaxSize: SizeInt = 0; MinCount: Integer = 0);
var
  C: Char;
begin
  FMemo          := Memo;
  FSteps         := TSteps.Create(MaxSize, MinCount);

  with FSteps do begin
    for C in Delimiters do
      Include(FDelimiters, C);

    FMaxWordLen := MaxWordLen;
  end;

  FOldOnChange   := FMemo.OnChange;
  FMemo.OnChange := @MemoOnChange;
                                
  FOldApplicationIdle := Application.OnIdle;
  Application.OnIdle  := @ApplicationIdle;

  FPrevContent   := FMemo.Text;
  // FPrevSelStart  := FMemo.SelStart;

  FHalf          := False;
  FInEdit        := True;
  FixOnChangeBug := False;

  FAutoSelStart  := 0;
end;


destructor THistory.Destroy;
begin
  FMemo.OnChange     := FOldOnChange;
  Application.OnIdle := FOldApplicationIdle;
  inherited Destroy;
end;


function THistory.GetSize: SizeInt;
begin
  Result := FSteps.FSize;
end;


function THistory.GetIndex: Integer;
begin
  Result := FSteps.FIndex;
end;


function THistory.GetCount: Integer;
begin
  Result := FSteps.FCount;
end;


procedure THistory.MemoOnChange(Sender: TObject);
var
  Content      : String;
  Len          : SizeInt;
  ByteSelStart : SizeInt;

  // Positive value means added content, negative value means
  // deleted content, based on 1
  // 正数表示添加内容，负数表示删除内容，从 1 开始计数
  SelStart  : SizeInt;
  SelLength : SizeInt;
  SelText   : String;


  procedure HardCalc();
  var
    A, B, E: PChar;
  begin
    A := PChar(Content);
    B := PChar(FPrevContent);

    // Ends with a shorter string length
    // 以较短的字符串长度为结束位置
    if Len < 0 then
      E := A + Length(Content)
    else
      E := A + Length(FPrevContent);

    // Compare byte by byte
    // 逐字节比较
    while A < E do begin
      if A^ <> B^ then Break;
      Inc(A);
      Inc(B);
    end;

    // Find the starting byte of the codepoint
    // 查找码点的起始字节
    while A > PChar(Content) do
      if A^ in [#0..#127, #192..#247] then
        Break
      else
        Dec(A);

    ByteSelStart := A - PChar(Content) + 1;                         
    SelStart     := UTF8LengthFast(PChar(Content), ByteSelStart);
    SelLength    := UTF8LengthFast(PChar(Content) + ByteSelStart, Len);
  end;


begin

  if FInEdit then begin

    Content      := FMemo.Text;
    Len          := Length(Content) - Length(FPrevContent);
    ByteSelStart := UTF8PosToBytePos(Content, FMemo.SelStart + 1);

    if Len > 0 then begin

// I can't distinguish between 'typing' and 'dragging text from outside to TMemo',
// so I commented out these code, they don't work exactly right unless you don't drag
// text from outside to TMemo. (these code can improve efficiency)

// 我无法区分键入操作和从外部拖拽文本到 TMemo 的操作，所以我把这些代码注释掉了，
// 它们不能完全正确工作，除非你不从 TMemo 外部向 TMemo 中拖拽内容（这些代码可以提高效率）

{
      // SelLength > 0 when drag and drop inside TMemo.
      // 在 TMemo 内拖拽时，SelLength > 0
      if FMemo.SelLength > 0 then
        HardCalc()

      else begin
        // Get the starting position and length of "added text"
        // 获取“新增数据”的起始位置和长度
        ByteSelStart := ByteSelStart - Len;
        SelLength    := UTF8LengthFast(PChar(Content) + ByteSelStart, Len);
        SelStart     := FMemo.SelStart - SelLength + 1;

        // SelStart > FPrevSelStart when typing text, SelStart = FPrevSelStart when
        // drag from outside TMemo and drop it behind the last typing position.
        // 键入操作时 SelStart > FPrevSelStart，从 TMemo 外部拖入内容并放到原来光标
        // 位置之后时 SelStart = FPrevSelStart
        if FMemo.SelStart = FPrevSelStart then
          HardCalc();

      end; 
}

      // If you enable the above code, you need to delete this function call and
      // enable the code related to FPrevSelStart
      HardCalc();

      SelText  := Copy(Content, ByteSelStart, Len);

    end

    else if Len < 0 then begin
      Len := -Len;
      // Get the starting position and length of the deleted data
      // 获取“被删除数据”的起始位置和长度
      SelLength := UTF8LengthFast(PChar(FPrevContent) + ByteSelStart, Len);
      // Positive value means added content, negative value means
      // deleted content, based on 1
      // 正数表示添加内容，负数表示删除内容，从 1 开始计数
      SelStart  := -(FMemo.SelStart + 1);
      SelText   := Copy(FPrevContent, ByteSelStart, Len);
    end

    else
      Exit;

    // Add history
    // 添加历史记录
    FSteps.Add(SelStart, SelLength, SelText, FHalf);

    FPrevContent := Content;
    FHalf := True;

  end;

  FixOnChangeBug := False;

  if Assigned(FOldOnChange) then
    FOldOnChange(Sender);
end;


procedure THistory.ApplicationIdle(Sender: TObject; var Done: Boolean);
begin
  // FPrevSelStart := FMemo.SelStart;

  FHalf := False;

  if Assigned(FOldApplicationIdle) then
    FOldApplicationIdle(Sender, Done);
end;


function THistory.CanUndo: Boolean; inline;
begin
  Result := FSteps.FIndex > 0;
end;


function THistory.CanRedo: Boolean; inline;
begin
  Result := FSteps.FIndex < FSteps.Count;
end;


// AutoSelect indicates whether to automatically select the undo content after undo
// AutoSelect 表示是否在撤销之后，自动选中被撤销的内容
procedure THistory.Undo(AutoSelect: Boolean = False);
var
  Half      : Integer;
  SelStart  : SizeInt;
  SelLength : SizeInt;
begin
  if FSteps.FIndex <= 0 then
    Exit;

  FInEdit := False;
  FixOnChangeBug := True;

  with FSteps.FCurrent do begin

    Half      := FHalf;
    SelStart  := FSelStart;
    SelLength := FSelLength;

    // Greater than 0 indicates that the user has added content before,
    // and Undo is to delete the content added by the user
    // 大于 0 表示用户之前添加了内容，Undo 就是删除用户添加的内容
    if FSelStart > 0 then begin
      // FSelStart based on 1, and TMemo.SelStart based on 0, so -1
      // FSelStart 是从 1 开始计数的，而 TMemo.SelStart 是从 0 开始计数的，所以这里要 -1
      FMemo.SelStart  := FSelStart - 1;
      FMemo.SelLength := FSelLength;
      FMemo.SelText   := '';
    end

    // Less than 0 indicates that the user has deleted the content before,
    // and Undo is to restore the content deleted by the user
    // 小于 0 表示用户之前删除了内容，Undo 就是恢复用户删除的内容
    else begin
      // Used to automatically select the undo content after undo, 
      // so that users can view the undo places
      // 用于在撤销之后，自动选中被撤销的内容，便于用户查看那些地方被撤销
      FAutoSelStart := -FSelStart;    
      // FSelStart based on 1, and TMemo.SelStart based on 0, so -1
      // FSelStart 是从 1 开始计数的，而 TMemo.SelStart 是从 0 开始计数的，所以这里要 -1
      FMemo.SelStart  := FAutoSelStart - 1;
      FMemo.SelLength := 0;
      FMemo.SelText   := FSelText;
    end;

  end;

  FSteps.Prev;

  FPrevContent := FMemo.Text;

  if FixOnChangeBug then
    MemoOnChange(FMemo);

  FInEdit := True;

  // Trigger another half undo operation
  // 触发另外半个 Undo 操作
  if Half = 2 then
    Undo(AutoSelect);

  if AutoSelect then begin

    if (SelStart < 0) then begin
      // Undo restores the previously deleted data
      // Undo 恢复了之前删除的数据
      FMemo.SelStart := FAutoSelStart - 1;
      FMemo.SelLength := SelLength;
    end

    else if (Half = 1) and (SelStart <= FAutoSelStart) then
      // Undo deleted the previously added data
      // Undo 删除了之前添加的数据
      FAutoSelStart := FAutoSelStart - SelLength;

  end;

end;


procedure THistory.Redo(AutoSelect: Boolean);
var
  Half      : Integer;
  SelStart  : SizeInt;
  SelLength : SizeInt;
begin
  if FSteps.FIndex > FSteps.Count then
    Exit;

  FInEdit := False;

  FixOnChangeBug := True;

  FSteps.Next;

  with FSteps.FCurrent do begin

    Half      := FHalf;
    SelStart  := FSelStart;
    SelLength := FSelLength;

    if SelStart > 0 then begin
      FAutoSelStart   := FSelStart;
      FMemo.SelStart  := FSelStart - 1;
      FMemo.SelLength := 0;
      FMemo.SelText   := FSelText;
    end

    else begin
      FMemo.SelStart  := -FSelStart - 1;
      FMemo.SelLength := FSelLength;
      FMemo.SelText   := '';
    end;
  end;

  FPrevContent := FMemo.Text;

  if FixOnChangeBug then
    MemoOnChange(FMemo);

  FInEdit := True;

  // Trigger another half redo operation
  // 触发另外半个 Redo 操作
  if Half = 1 then
    Redo(AutoSelect);

  if AutoSelect then begin

    if (SelStart > 0) then begin
      // Redo restores the previously deleted data
      // Redo 恢复了之前删除的数据
      FMemo.SelStart := FAutoSelStart - 1;
      FMemo.SelLength := SelLength;
    end

    else if (Half = 2) and (-SelStart <= FAutoSelStart) then
      // Redo deleted the previously added data
      // Redo 删除了之前添加的数据
      FAutoSelStart := FAutoSelStart - SelLength;

  end;

end;


// Please use this function to perform paste operation, which can improve efficiency
// 请使用该函数执行粘贴操作，它可以提高效率
procedure THistory.PasteText;
var
  ClipBoardText: string;
begin
  ClipBoardText := ClipBoard.AsText;
  if ClipBoardText = '' then Exit;

  if FMemo.SelLength > 0 then begin
    FSteps.Add(-(FMemo.SelStart+1), FMemo.SelLength, FMemo.SelText, False);
    FSteps.Add(FMemo.SelStart + 1, UTF8LengthFast(ClipBoardText), ClipBoardText, True);
  end else
    FSteps.Add(FMemo.SelStart + 1, UTF8LengthFast(ClipBoardText), ClipBoardText, False);

  FInEdit := False;
  FixOnChangeBug := True;

  FMemo.SelText := ClipBoardText;
  FPrevContent  := FMemo.Text;

  if FixOnChangeBug then
    MemoOnChange(FMemo);

  FInEdit := True;
end;


// Clean up the history data
// 清空历史记录数据
procedure THistory.Reset; inline;
begin
  FSteps.Reset;
end;

end.

