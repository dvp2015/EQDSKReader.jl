var documenterSearchIndex = {"docs":
[{"location":"api/","page":"API","title":"API","text":"CurrentModule = EQDSKReader ","category":"page"},{"location":"api/#API","page":"API","title":"API","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"","category":"page"},{"location":"api/","page":"API","title":"API","text":"Modules = [EQDSKReader]\nOrder = [:module, :type, :function, :macro]","category":"page"},{"location":"api/#EQDSKReader.EQDSKReader","page":"API","title":"EQDSKReader.EQDSKReader","text":"EQDSKReader\n\nProvides functionality to read EQDSK file.\n\n\n\n\n\n","category":"module"},{"location":"api/#EQDSKReader.Content","page":"API","title":"EQDSKReader.Content","text":"Content\n\nContent of EQDSK file.\n\nAttrs:\n\ncase    identification character string\nnw      number of horizontal grid points\nnh      number of vertical grid points\nrdim    horizontal dimension in metter of computational box\nzdim    vertical dimension in metter of computational box\nrcentr  R in meter of vacuum toroidal magnetic field BCENTR\nrleft   Minimum R in meter of rectangular computational box\nzmid    Z of center of computational box in meter\nrmaxis  R of magnetic axis in meter\nzmaxis  Z of magnetic axis in meter\nsimag   poloidal flux at magnetic axis in Weber /rad\nsibry   poloidal flux at the plasma boundary in Weber /rad\nbcentr  Vacuum toroidal magnetic field in Tesla at RCENTR\ncurrent Plasma current in Ampere\nfpol    Poloidal current function in m-T, F = RB_T on flux grid\npres    Plasma pressure in nt / m^2 on uniform flux grid\nffprim  FF’(ψ) in (mT)^2 / (Weber /rad) on uniform flux grid\npprime  P’(ψ) in (nt/m^2 ) / (Weber /rad) on uniform flux grid\npsirz   Poloidal flux in Weber / rad on the rectangular grid points\nqpsi    q values on uniform flux grid from axis to boundary\nnbbbs   Number of boundary points\nlimitr  Number of limiter points\nrbbbs   R of boundary points in meter\nzbbbs   Z of boundary points in meter\nrlim    R of surrounding limiter contour in meter\nzlim    Z of surrounding limiter contour in mete\n\n\n\n\n\n","category":"type"},{"location":"api/#EQDSKReader.Content-Tuple{AbstractString}","page":"API","title":"EQDSKReader.Content","text":"Content(path::AbstractString)\n\nBuild Content object from a file with a in EQDSK format.\n\n\n\n\n\n","category":"method"},{"location":"api/#EQDSKReader.Content-Tuple{IO}","page":"API","title":"EQDSKReader.Content","text":"Content(io::IO)\n\nBuild Content object from an input stream with a in EQDSK format.\n\n\n\n\n\n","category":"method"},{"location":"api/#EQDSKReader.read_eqdsk-Tuple{IO}","page":"API","title":"EQDSKReader.read_eqdsk","text":"read_eqdsk(io::IO)\n\nReads a stream according to spec found in G_EQDSK.pdf.\n\nreturns\n\n[`Content`](@ref)\n\n\n\n\n\n","category":"method"},{"location":"","page":"Home","title":"Home","text":"CurrentModule = EQDSKReader","category":"page"},{"location":"#EQDSKReader","page":"Home","title":"EQDSKReader","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for EQDSKReader.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Pages = [\"index.md\", \"api.md\"]","category":"page"}]
}
