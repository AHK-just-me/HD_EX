; ======================================================================================================================
; Namespace:      HD_EX
; Function:       Some functions to use with header controls (HD).
; Tested with:    AHK 1.1.13.01 (A32/U32/U64)
; Tested on:      Win 7 (x64)
; Changelog:
;     1.0.00.00/2014-01-21/just me - initial release
; Common function parameters:
;     HHD         -  Handle to the header control.
;     Index       -  1-based index of the header item (column).
; ======================================================================================================================
; This software is provided 'as-is', without any express or implied warranty.
; In no event will the authors be held liable for any damages arising from the use of this software.
; ======================================================================================================================
; Insert          Inserts a new item into a header control.
; Parameters:     Text   - Item's text/label.
;                 Width  - Width of the item, in pixels.
;                 Format - String containing one of the format strings defined in HDF. Default: "Left"
;                          HDF_STRING will be added internally, if Text contains a string.
; Return values:  Returns the index of the new item if successful, or -1 otherwise.
; Remarks:        The new item is inserted at the end of the header control if index is greater than the number of
;                 items in the control. If Index is one, the item is inserted at the beginning of the header control.
; ======================================================================================================================
HD_EX_Insert(HHD, Index, Text, Width, Format := "Left") {
   Static HDM_INSERTITEM := A_IsUnicode ? 0x120A : 0x1201 ; HDM_INSERTITEMW : HDM_INSERTITEMA
   Static HDF_STRING := 0x4000
   Static HDF := {Left: 0x0000, Right: 0x0001, Center: 0x0002}
   Static HDI_FORMAT := 0x0004
   Static HDI_TEXT := 0x0002
   Static HDI_WIDTH := 0x0001
   Static OffText := 8
   Static OffWidth := 4
   Static OffFmt := (4 * 3) + (A_PtrSize * 2)
   Mask := HDI_FORMAT | HDI_TEXT | HDI_WIDTH
   Fmt := 0
   If HDF.HasKey(Format)
      Fmt := HDF[Format]
   Else
      Fmt := HDF["Left"]
   If (Text <> "")
      Fmt |= HDF_STRING
   HD_EX_CreateHDITEM(HDITEM)
   NumPut(Mask, HDITEM, 0, "UInt")
   NumPut(Width, HDITEM, OffWidth, "Int")
   NumPut(&Text, HDITEM, OffText, "Ptr")
   NumPut(Fmt, HDITEM, OffFmt, "Int")
   SendMessage, % HDM_INSERTITEM, % (Index - 1), % &HDITEM, , % "ahk_id " . HHD
   Return (ErrorLevel + 1)
}
; ======================================================================================================================
; CreateHDITEM    Creates a HDITEM structure - for internal use!!!
; ======================================================================================================================
HD_EX_CreateHDITEM(ByRef HDITEM) {
   Static cbHDITEM := (4 * 6) + (A_PtrSize * 6)
   VarSetCapacity(HDITEM, cbHDITEM, 0)
   Return True
}
; ======================================================================================================================
; Delete          Deletes the specified item from a header control.
; Return values:  Returns True if successful, or False otherwise.
; ======================================================================================================================
HD_EX_Delete(HHD, Index) {
   Static HDM_DELETEITEM := 0x1202
   SendMessage, % HDM_DELETEITEM, % (Index - 1), 0, , % "ahk_id " . HHD
   Return ErrorLevel
}
; ======================================================================================================================
; GetCount        Gets the count of the items in a header control.
; Return values:  Returns the number of items if successful, or -1 otherwise.
; ======================================================================================================================
HD_EX_GetCount(HHD) {
   Static HDM_GETITEMCOUNT := 0x1200
   SendMessage, % HDM_GETITEMCOUNT, 0, 0, , % "ahk_id " . HHD
   Return ErrorLevel
}
; ======================================================================================================================
; GetData         Gets the application-defined data (lParam) of the specified item.
; Return values:  Returns the item data if successful, or 0 otherwise.
; ======================================================================================================================
HD_EX_GetData(HHD, Index) {
   Static HDM_GETITEM := A_IsUnicode ? 0x120B : 0x1203 ; HDM_GETITEMW : HDM_GETITEMA
   Static HDI_LPARAM := 0x0008
   Static OffData := (4 * 4) + (A_PtrSize * 2)
   HD_EX_CreateHDITEM(HDITEM)
   NumPut(HDI_LPARAM, HDITEM, 0, "UInt")
   SendMessage, % HDM_GETITEM, % (Index - 1), % &HDITEM, , % "ahk_id " . HHD
   Return NumGet(HDITEM, OffData, "Int")
}
; ======================================================================================================================
; GetFormat       Gets the format of the specified item.
; Return values:  Returns the current item format flags if successful, or 0 otherwise.
; ======================================================================================================================
HD_EX_GetFormat(HHD, Index) {
   Static HDM_GETITEM := A_IsUnicode ? 0x120B : 0x1203 ; HDM_GETITEMW : HDM_GETITEMA
   Static HDI_FORMAT := 0x0004
   Static OffFmt := (4 * 3) + (A_PtrSize * 2)
   HD_EX_CreateHDITEM(HDITEM)
   NumPut(HDI_FORMAT, HDITEM, 0, "UInt")
   SendMessage, % HDM_GETITEM, % (Index - 1), % &HDITEM, , % "ahk_id " . HHD
   Return NumGet(HDITEM, OffFmt, "Int")
}
; ======================================================================================================================
; GetRect         Gets the bounding rectangle for a given item in a header control.
; Return values:  Returns nonzero if successful, or zero otherwise.
; ======================================================================================================================
HD_EX_GetRect(HHD, Index, ByRef X := "", ByRef Y := "", ByRef W := "", ByRef H := "") {
   Static HDM_GETITEMRECT := 0x1207
   X := Y := W := H := 0
   VarSetCapacity(RECT, 16, 0)
   SendMessage, % HDM_GETITEMRECT, % (Index - 1), % &RECT, , % "ahk_id " . HHD
   If (ErrorLevel) {
      X := NumGet(RECT, 0, "Int")
      Y := NumGet(RECT, 4, "Int")
      W := NumGet(RECT, 8, "Int") - X
      H := NumGet(RECT, 12, "Int") - Y
      Return True
   }
   Return False
}
; ======================================================================================================================
; SetBitmap       Assigns a bitmap to the specified item.
; Parameters:     HBITMAP - Handle to the bitmap.
; Return values:  Returns nonzero upon success, or zero otherwise.
; ======================================================================================================================
HD_EX_SetBitmap(HHD, Index, HBITMAP) {
   Static HDM_SETITEM := A_IsUnicode ? 0x120C : 0x1204 ; HDM_SETITEMW : HDM_SETITEMA
   Static HDI_BITMAP := 0x0010
   Static HDI_FORMAT := 0x0004
   Static HDF_BITMAP := 0x2000
   Static OffBmp := (4 * 2) + A_PtrSize
   Static OffFmt := (4 * 3) + (A_PtrSize * 2)
   Mask := HDI_FORMAT | HDI_BITMAP
   Fmt := HD_EX_GetFormat(HHD, Index) | HDF_BITMAP
   Fmt := HDF_BITMAP
   HD_EX_CreateHDITEM(HDITEM)
   NumPut(Mask, HDITEM, 0, "UInt")
   NumPut(HBITMAP, HDITEM, OffBmp, "UPtr")
   NumPut(Fmt, HDITEM, OffFmt, "Int")
   SendMessage, % HDM_SETITEM, % (Index - 1), % &HDITEM, , % "ahk_id " . HHD
   Return ErrorLevel
}
; ======================================================================================================================
; SetBitmapMargin Sets the width of the margin, specified in pixels, of a bitmap in a header control.
; Parameters:     Width - Margin width in pixels.
; Return values:  Returns the width of the bitmap margin, in pixels.
; Note:           A value of -3 seems to set the margin to zero!!!
; ======================================================================================================================
HD_EX_SetBitmapMargin(HHD, Width) {
   Static HDM_SETBITMAPMARGIN := 0x1214
   SendMessage, % HDM_SETBITMAPMARGIN, % Width, 0, , % "ahk_id " . HHD
   Return ErrorLevel
}
; ======================================================================================================================
; SetData         Sets application-defined data (lParam) of the specified item.
; Parameters:     Data - Integer value.
; Return values:  Returns nonzero upon success, or zero otherwise.
; ======================================================================================================================
HD_EX_SetData(HHD, Index, Data) {
   Static HDM_SETITEM := A_IsUnicode ? 0x120C : 0x1204 ; HDM_SETITEMW : HDM_SETITEMA
   Static HDI_LPARAM := 0x0008
   Static OffData := (4 * 4) + (A_PtrSize * 2)
   HD_EX_CreateHDITEM(HDITEM)
   NumPut(HDI_LPARAM, HDITEM, 0, "UInt")
   NumPut(Data, HDITEM, OffData, "UPtr")
   SendMessage, % HDM_SETITEM, % (Index - 1), % &HDITEM, , % "ahk_id " . HHD
   Return ErrorLevel
}
; ======================================================================================================================
; SetFormat       Sets the format of the specified item.
; Parameters:     FormatArray - Array containing one ore more of the format strings defined in HDF.
;                 Exclusive   - If False, the passed format flags will be added using a bitwise-or operation.
;                               Otherwise, existing format flags will be reset.
; Return values:  Returns nonzero upon success, or zero otherwise.
; ======================================================================================================================
HD_EX_SetFormat(HHD, Index, FormatArray, Exclusive := False) {
   Static HDM_SETITEM := A_IsUnicode ? 0x120C : 0x1204 ; HDM_SETITEMW : HDM_SETITEMA
   Static HDF := {Left: 0x0000, Right: 0x0001, Center: 0x0002
                , Bitmap: 0x2000, BitmapOnRight: 0x1000, OwnerDraw: 0x8000, String: 0x4000
                , Image: 0x0800, RtlReading: 0x0004, SortDown: 0x0200, SortUp: 0x0400}
   Static HDI_FORMAT := 0x0004
   Static OffFmt := (4 * 3) + (A_PtrSize * 2)
   Fmt := Exclusive ? 0 : HD_EX_GetFormat(HDD, Index)
   For Each, Format In FormatArray
      If HDF.HasKey(Format)
         Fmt |= HDF[Format]
   HD_EX_CreateHDITEM(HDITEM)
   NumPut(HDI_FORMAT, HDITEM, 0, "UInt")
   NumPut(Fmt, HDITEM, OffFmt, "UInt")
   SendMessage, % HDM_SETITEM, % (Index - 1), % &HDITEM, , % "ahk_id " . HHD
   Return ErrorLevel
}
; ======================================================================================================================
; SetImage        Sets an image from the header's image list for the specified item.
; Parameters:     Image - 1-based index of the image in the image list.
; Return values:  Returns nonzero upon success, or zero otherwise.
; ======================================================================================================================
HD_EX_SetImage(HHD, Index, Image) {
   Static HDM_SETITEM := A_IsUnicode ? 0x120C : 0x1204 ; HDM_SETITEMW : HDM_SETITEMA
   Static HDF_IMAGE := 0x0800
   Static HDI_FORMAT := 0x0004
   Static HDI_IMAGE  := 0x0020
   Static OffFmt := (4 * 3) + (A_PtrSize * 2)
   Static OffImg := (4 * 4) + (A_PtrSize * 3)
   Mask := HDI_FORMAT | HDI_IMAGE
   Fmt := HD_EX_GetFormat(HHD, Index) | HDF_IMAGE
   HD_EX_CreateHDITEM(HDITEM)
   NumPut(Mask, HDITEM, 0, "UInt")
   NumPut(Fmt, HDITEM, OffFmt, "Int")
   NumPut(Image - 1, HDITEM, OffImg, "Int")
   SendMessage, % HDM_SETITEM, % (Index - 1), % &HDITEM, , % "ahk_id " . HHD
   Return ErrorLevel
}
; ======================================================================================================================
; SetImageList    Assigns an image list to a header control.
; Parameters:     HIL - Handle to the image list.
; Return values:  Returns 0 upon failure or if no image list was set previously; otherwise it returns the handle to
;                 the image list previously associated with the control.
; ======================================================================================================================
HD_EX_SetImageList(HHD, HIL) {
   Static HDM_SETIMAGELIST := 0x1208
   Static HDSIL_NORMAL := 0
   SendMessage, % HDM_SETIMAGELIST, % HDSIL_NORMAL, % HIL, , % "ahk_id " . HHD
   Return ErrorLevel
}