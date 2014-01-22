#NoEnv
#Include HD_EX.ahk
SetBatchLines, -1
ShowNotifications := False ; set to true to get a additional list box in which the notifications are shown
; ----------------------------------------------------------------------------------------------------------------------
Notifications := {-5: "NM_RCLICK", -7: "NM_SETFOCUS", -12: "NM_CUSTOMDRAW", -16: "NM_RELEASEDCAPTURE"
                , -322: "HDN_ITEMCLICKW", -323: "HDN_ITEMDBLCLICKW"}
; ----------------------------------------------------------------------------------------------------------------------
ILID := IL_Create(10)
Loop, 10
   IL_Add(ILID, "Shell32.dll", A_Index)
; ----------------------------------------------------------------------------------------------------------------------
HDN_ITEMCLICK := A_IsUnicode ? -322 : -302 ; HDN_ITEMCLICKW : HDN_ITEMCLICKA
HDS_BUTTONS := "+0x0002"
WM_KILLFOCUS := 0x0008
; ----------------------------------------------------------------------------------------------------------------------
Gui, Margin, 20, 20
Gui, Add, Custom, CLassSysHeader32 w400 h22 vHD1 hwndHHD1 %HDS_BUTTONS%
Gui, Font
Items := 4
Loop, % Items
   HD_EX_Insert(HHD1, Items + 1, A_Index = 1 ? "Clear" : "Header " . A_Index, 100)
HD_EX_SetImageList(HHD1, ILID)
Loop, 4
   HD_EX_SetImage(HHD1, A_Index, A_Index + 5)
; ImagePath := "C:\AHK_L\AutoHotkey_logo.gif"
; HD_EX_SetBitmapMargin(HHD1, -3)
; HD_EX_GetRect(HHD1, 1, , , W, H)
; HBITMAP := LoadImage(ImagePath, W, H)
; HD_EX_SetBitmap(HHD1, 1, HBITMAP)
GuiControl, +gSubHD1, HD1
If (ShowNotifications) {
   Gui, Add, ListBox, w400 r20 vLB1
   Gui, Add, Button, gClear, Clear
}
Gui, Add, StatusBar
Gui, Show, , Header Control
Return
; ----------------------------------------------------------------------------------------------------------------------
GuiClose:
ExitApp
; ----------------------------------------------------------------------------------------------------------------------
GuiSize:
PostMessage, % WM_KILLFOCUS, 0, 0, , % "ahk_id " . HHD1 ; needed, if the header gets the focus when the GUI is shown
Return
; ----------------------------------------------------------------------------------------------------------------------
Clear:
   If (ShowNotifications)
      GuiControl, , LB1, |
   SB_SetText("   StatusBar was cleared!")
Return
; ----------------------------------------------------------------------------------------------------------------------
Click2:
CLick3:
Click4:
   SB_SetText("   Click on header " . SubStr(A_ThisLabel, 6))
Return
; ----------------------------------------------------------------------------------------------------------------------
SubHD1:
   Critical
   Msg := NumGet(A_EventInfo + 0, A_PtrSize * 2, "Int")
   Item := NumGet(A_EventInfo + 0, A_PtrSize * 3, "Int") + 1
   If (ShowNotifications) {
      If (A_GuiEvent = "N") {
         MsgOut := Notifications.HasKey(Msg) ? Notifications[Msg] : "Unknown: " . Msg
         GuiControl, , LB1, % "WM_NOTIFY: " . MsgOut . (Msg > -310 ? "" : " - " . Item)
      }
      Else If (A_GuiEvent = "Normal")
         GuiControl, , LB1, % "WM_COMMAND: " A_EventInfo
      Else
         GuiControl, , LB1, % "*ERROR*: A_GuiEvent = " . A_GuiEvent
   }
   If (A_GuiEvent != "N")
      Return
   If (Msg = HDN_ITEMCLICK) {
      If (Item = 1)
         GoSub, Clear
      Else
         GoSub, Click%Item%
   }
Return
; ----------------------------------------------------------------------------------------------------------------------
LoadImage(ImagePath, W := 0, H := 0) {
   Dll := DllCall("Kernel32.dll\LoadLibrary", "Str", "Gdiplus.dll", "Ptr")
   VarSetCapacity(SI, 24, 0), Numput(1, SI, 0, "UInt")
   DllCall("Gdiplus.dll\GdiplusStartup", "PtrP", Token, "Ptr", &SI, "Ptr", 0)
   DllCall("Gdiplus.dll\GdipCreateBitmapFromFile", "WStr", ImagePath, "PtrP", Bitmap)
   DllCall("Gdiplus.dll\GdipCreateHBITMAPFromBitmap", "Ptr", Bitmap, "PtrP", HBITMAP, "UInt", 0xFFFFFFFF)
   DllCall("Gdiplus.dll\GdipDisposeImage", "Ptr", Bitmap)
   DllCall("Gdiplus.dll\GdiplusShutdown", "Ptr", Token)
   DllCall("Kernel32.dll\FreeLibrary", "Ptr", Dll)
   If (W <> 0) || (H <> 0)
      HBITMAP := DllCall("User32.dll\CopyImage", "Ptr", HBITMAP, "UInt", 0, "Int", W, "Int", H, "UInt", 0x0C)
   Return HBITMAP
}