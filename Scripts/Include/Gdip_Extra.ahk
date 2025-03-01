
Gdip_ResizeBitmap(pBitmap, PercentOrWH, Dispose=1) {   ; returns resized bitmap. By Learning one.
	; http://www.autohotkey.com/forum/post-477333.html#477333
   Gdip_GetImageDimensions(pBitmap, origW, origH)
   if PercentOrWH contains w,h
   {
      RegExMatch(PercentOrWH, "i)w(\d*)", w), RegExMatch(PercentOrWH, "i)h(\d*)", h)
      NewWidth := w1, NewHeight := h1
      NewWidth := (NewWidth = "") ? origW/(origH/NewHeight) : NewWidth
      NewHeight := (NewHeight = "") ? origH/(origW/NewWidth) : NewHeight
   }
   else
   NewWidth := origW*PercentOrWH/100, NewHeight := origH*PercentOrWH/100      
   pBitmap2 := Gdip_CreateBitmap(NewWidth, NewHeight)
   G2 := Gdip_GraphicsFromImage(pBitmap2), Gdip_SetSmoothingMode(G2, 4), Gdip_SetInterpolationMode(G2, 7)
   Gdip_DrawImage(G2, pBitmap, 0, 0, NewWidth, NewHeight)
   Gdip_DeleteGraphics(G2)
   if Dispose
      Gdip_DisposeImage(pBitmap)
   return pBitmap2
}

Gdip_CropImage(pBitmap, x, y, w, h) {
	pBitmap2 := Gdip_CreateBitmap(w, h), G2 := Gdip_GraphicsFromImage(pBitmap2)
	Gdip_DrawImage(G2, pBitmap, 0, 0, w, h, x, y, w, h)
	Gdip_DeleteGraphics(G2)
	return pBitmap2
}