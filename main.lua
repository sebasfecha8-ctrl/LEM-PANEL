--[[
    Panel v23.1 - Combate PRO + Aimbot ARREGLADO + Trayectoria
    LocalScript | StarterPlayer > StarterPlayerScripts
    E = Aimbot | V = ESP | X = Anti-aim | P = panico | RightShift = ocultar
]]

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local SoundService      = game:GetService("SoundService")
local HttpService       = game:GetService("HttpService")
local Debris            = game:GetService("Debris")
local VirtualUser       = game:GetService("VirtualUser")
local Stats             = game:GetService("Stats")

local jugador = Players.LocalPlayer
local camara  = workspace.CurrentCamera

-- =========================================================
-- CLEANUP
-- =========================================================
local pg = jugador:WaitForChild("PlayerGui")
for _, obj in ipairs(pg:GetChildren()) do
    if obj:IsA("ScreenGui") then
        local n = obj.Name
        if n == "PanelCombinado" or n == "PanelAimbot" or n == "AimPanel"
        or n == "MarcasESP" or n == "LineasESP" or n == "ContadorStuds" then
            obj:Destroy()
        end
    end
end
task.wait(0.1)

-- =========================================================
-- CONFIG
-- =========================================================
local cfg = {
    Aimbot            = false,
    SoloClickDerecho  = false,
    TrabarObjetivo    = true,
    PriorizarCercano  = false,
    PriorizarPocaVida = false,
    PriorizarAmenaza  = false,
    PriorizarCabeza   = true,
    AimCercanoCursor  = false,
    FovRadio          = 200,
    FovDinamico       = false,
    FovPorDistancia   = false,
    FovPorDistanciaMax= 300,
    FovMinimo         = 60,
    Suavidad          = 60,
    CurvaSuavizado    = 1,
    AimRestriccion    = 90,
    AntiShake         = false,
    AntiShakeForce    = 0.15,
    AutoFireHold      = false,
    AutoFireTecla     = Enum.KeyCode.F,
    AutoFireMs        = 100,
    Rango3D           = 2000,
    DistanciaDisparo  = 2000,
    IgnorarEquipo     = true,
    VerificarParedes  = true,
    PrediccionGravedad= false,
    GravedadBala      = 196,

    Triggerbot        = false,
    TriggerDelay      = 80,
    TriggerRango      = 300,
    TriggerRafaga     = 1,
    TriggerRafagaMs   = 100,

    AntiAim           = false,
    AntiAimModo       = 1,
    AntiAimVel        = 1000,

    ESP               = true,
    ESPVida           = true,
    ESPArma           = false,
    ESPBox            = false,
    ESPSkeleton       = false,
    OffScreenInd      = false,
    MostrarFOV        = true,
    RangoESP          = 2000,
    HitboxJugador     = false,
    Chams             = true,
    ESPColor          = 1,

    ContadorStuds     = true,
    LineasStuds       = true,
    LineasOrigen      = 1,
    ColorLineas       = 1,
    GrosorLineas      = 1.5,

    AntiVoid          = true,
    AntiVoidY         = -50,
    AntiAFK           = true,
    AutoRespawn       = true,
    DetectarAimbots   = true,
    Notificaciones    = true,

    UsarTrayectoria   = false,
    TrayectoriaLoop   = true,
    TrayectoriaSlots  = {
        "Head", "Head", "Head", "Torso", "Head",
        "Head", "Head", "Torso", "Head", "Head",
    },
    TrayectoriaActiva = 0,

    MarcadorTiro      = true,
    LineaTiro         = false,
    Prediccion        = false,
    PrediccionMs      = 80,

    SonidoKill        = true,
    SonidoTipo        = 1,
    SonidoCustom      = "",
    Volumen           = 1,
    SonidosUI         = true,

    MostrarKills      = true,
    MostrarRacha      = true,
    EfectoKill        = true,
    KillFeed          = true,
    MostrarHUDInfo    = true,

    TemaActual        = 1,
    UsarColorCustom   = false,
    ColorCustom       = Color3.fromRGB(0, 220, 90),

    TeclaAimbot       = Enum.KeyCode.E,
    TeclaESP          = Enum.KeyCode.V,
    TeclaAntiAim      = Enum.KeyCode.X,
    TeclaOcultar      = Enum.KeyCode.RightShift,
    TeclaPanico       = Enum.KeyCode.P,

    Debug             = false,
    _AutoFireActivo   = false,
    _TrayectoriaIdx   = 1,
    _SlotSeleccionado = 1,
}

local CLAMPS = {
    FovRadio = {40, 500}, FovMinimo = {20, 300}, Suavidad = {1, 100},
    CurvaSuavizado = {1, 4}, Rango3D = {200, 5000}, DistanciaDisparo = {200, 5000},
    TriggerDelay = {0, 500}, TriggerRango = {50, 1000},
    TriggerRafaga = {1, 10}, TriggerRafagaMs = {20, 500},
    AntiAimModo = {1, 3}, AntiAimVel = {100, 3000},
    ESPColor = {1, 6}, RangoESP = {200, 5000},
    LineasOrigen = {1, 2}, ColorLineas = {1, 6}, GrosorLineas = {0.5, 6},
    AntiVoidY = {-500, 0}, PrediccionMs = {0, 300},
    SonidoTipo = {1, 4}, Volumen = {0.1, 3},
    TemaActual = {1, 8},
    GravedadBala = {50, 500}, FovPorDistanciaMax = {100, 5000},
    AimRestriccion = {5, 180}, AntiShakeForce = {0.01, 0.5}, AutoFireMs = {20, 500},
    TrayectoriaActiva = {0, 10},
}

local UMBRAL_TRANSPARENCIA = 0.8
local IGNORAR_SIN_COLISION = true

-- =========================================================
-- COLORES
-- =========================================================
local COLORES_ESP = {
    { nombre = "Rojo",     color = Color3.fromRGB(255, 60, 60) },
    { nombre = "Verde",    color = Color3.fromRGB(60, 255, 100) },
    { nombre = "Cian",     color = Color3.fromRGB(0, 220, 255) },
    { nombre = "Amarillo", color = Color3.fromRGB(255, 220, 40) },
    { nombre = "Magenta",  color = Color3.fromRGB(255, 60, 220) },
    { nombre = "Blanco",   color = Color3.fromRGB(240, 240, 240) },
}
local NOMBRES_COLORES = {}
for i, c in ipairs(COLORES_ESP) do NOMBRES_COLORES[i] = c.nombre end

local COLORES_LINEA = {
    { nombre = "Blanco",  color = Color3.fromRGB(255, 255, 255) },
    { nombre = "Rojo",    color = Color3.fromRGB(255, 60, 60) },
    { nombre = "Verde",   color = Color3.fromRGB(60, 255, 100) },
    { nombre = "Cian",    color = Color3.fromRGB(0, 220, 255) },
    { nombre = "Amarillo",color = Color3.fromRGB(255, 220, 40) },
    { nombre = "Violeta", color = Color3.fromRGB(180, 90, 255) },
}
local NOMBRES_LINEAS = {}
for i, c in ipairs(COLORES_LINEA) do NOMBRES_LINEAS[i] = c.nombre end

-- =========================================================
-- TEMAS
-- =========================================================
local TEMAS = {
    { nombre = "Verde",    acento = Color3.fromRGB(0, 220, 90),   acento2 = Color3.fromRGB(120, 255, 160), fondo = Color3.fromRGB(12, 16, 22) },
    { nombre = "Amarillo", acento = Color3.fromRGB(255, 210, 0),  acento2 = Color3.fromRGB(255, 240, 120), fondo = Color3.fromRGB(18, 16, 10) },
    { nombre = "Rojo",     acento = Color3.fromRGB(255, 50, 50),  acento2 = Color3.fromRGB(255, 130, 100), fondo = Color3.fromRGB(20, 12, 12) },
    { nombre = "Naranja",  acento = Color3.fromRGB(255, 130, 0),  acento2 = Color3.fromRGB(255, 190, 80),  fondo = Color3.fromRGB(20, 14, 10) },
    { nombre = "Lima",     acento = Color3.fromRGB(180, 255, 60), acento2 = Color3.fromRGB(230, 255, 150), fondo = Color3.fromRGB(14, 20, 10) },
    { nombre = "Dorado",   acento = Color3.fromRGB(220, 180, 40), acento2 = Color3.fromRGB(255, 220, 120), fondo = Color3.fromRGB(20, 17, 10) },
    { nombre = "Cian",     acento = Color3.fromRGB(0, 200, 220),  acento2 = Color3.fromRGB(120, 240, 255), fondo = Color3.fromRGB(10, 18, 22) },
    { nombre = "Violeta",  acento = Color3.fromRGB(170, 90, 255), acento2 = Color3.fromRGB(220, 170, 255), fondo = Color3.fromRGB(16, 12, 22) },
}
local NOMBRES_TEMAS = {}
for i, t in ipairs(TEMAS) do NOMBRES_TEMAS[i] = t.nombre end

local T = {
    fondo       = TEMAS[cfg.TemaActual].fondo,
    fondoSuave  = TEMAS[cfg.TemaActual].fondo:Lerp(Color3.new(1,1,1), 0.05),
    tarjeta     = Color3.fromRGB(26, 26, 34),
    tarjeta2    = Color3.fromRGB(36, 36, 46),
    acento      = TEMAS[cfg.TemaActual].acento,
    acento2     = TEMAS[cfg.TemaActual].acento2,
    on          = Color3.fromRGB(60, 220, 130),
    off         = Color3.fromRGB(60, 62, 78),
    texto       = Color3.fromRGB(240, 242, 255),
    sub         = Color3.fromRGB(150, 155, 180),
    rojo        = Color3.fromRGB(255, 90, 100),
    amarillo    = Color3.fromRGB(255, 200, 0),
    verde       = Color3.fromRGB(0, 255, 100),
}

local COLOR_APAGADO  = Color3.fromRGB(255, 255, 255)
local COLOR_ACTIVO   = T.amarillo
local COLOR_OBJETIVO = T.verde

-- =========================================================
-- GUARDADO / CARGA
-- =========================================================
local ARCHIVO = "aimpanel_config.json"
local ARCHIVO_PERFILES = "aimpanel_perfiles.json"

local function aplicarClamps()
    for k, r in pairs(CLAMPS) do
        if type(cfg[k]) == "number" then
            cfg[k] = math.clamp(cfg[k], r[1], r[2])
        end
    end
end

local function serializar()
    local data = {}
    for k, v in pairs(cfg) do
        if typeof(v) == "EnumItem" then
            data[k] = { __enum = true, tipo = tostring(v.EnumType), nombre = v.Name }
        elseif typeof(v) == "Color3" then
            data[k] = { __color = true, r = v.R, g = v.G, b = v.B }
        else
            data[k] = v
        end
    end
    return data
end

local function deserializar(data)
    for k, v in pairs(data) do
        if type(v) == "table" and v.__enum then
            local ok, enumItem = pcall(function() return Enum[v.tipo][v.nombre] end)
            if ok then cfg[k] = enumItem end
        elseif type(v) == "table" and v.__color then
            cfg[k] = Color3.new(v.r, v.g, v.b)
        else
            cfg[k] = v
        end
    end
    aplicarClamps()
end

local function guardarConfig()
    if not writefile then return end
    local ok, json = pcall(function() return HttpService:JSONEncode(serializar()) end)
    if ok then pcall(writefile, ARCHIVO, json) end
end

local function cargarConfig()
    if not (isfile and readfile) then return end
    if not isfile(ARCHIVO) then return end
    local ok, data = pcall(function() return HttpService:JSONDecode(readfile(ARCHIVO)) end)
    if ok and type(data) == "table" then deserializar(data) end
end

cargarConfig()
aplicarClamps()

local perfiles = {}
local function cargarPerfiles()
    if not (isfile and readfile) then return end
    if not isfile(ARCHIVO_PERFILES) then return end
    local ok, data = pcall(function() return HttpService:JSONDecode(readfile(ARCHIVO_PERFILES)) end)
    if ok and type(data) == "table" then
        for i = 1, 3 do
            if data[i] then perfiles[i] = data[i] end
        end
    end
end
local function guardarPerfiles()
    if not writefile then return end
    local ok, json = pcall(function() return HttpService:JSONEncode(perfiles) end)
    if ok then pcall(writefile, ARCHIVO_PERFILES, json) end
end
cargarPerfiles()

-- =========================================================
-- SONIDOS UI
-- =========================================================
local SONIDO_HOVER = "rbxasset://sounds/electronicpingshort.wav"
local SONIDO_CLICK = "rbxasset://sounds/clickfast.wav"

local function sonarUI(tipo)
    if not cfg.SonidosUI then return end
    local s = Instance.new("Sound")
    s.SoundId = tipo == "click" and SONIDO_CLICK or SONIDO_HOVER
    s.Volume = 0.15
    s.Parent = SoundService
    s:Play()
    Debris:AddItem(s, 1)
end

-- =========================================================
-- GUI BASE
-- =========================================================
local gui = Instance.new("ScreenGui")
gui.Name = "PanelCombinado"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.Parent = pg

local circulo = Instance.new("Frame")
circulo.AnchorPoint = Vector2.new(0.5, 0.5)
circulo.Position = UDim2.fromScale(0.5, 0.5)
circulo.BackgroundTransparency = 1
circulo.Parent = gui
Instance.new("UICorner", circulo).CornerRadius = UDim.new(1, 0)
local borde = Instance.new("UIStroke")
borde.Thickness = 2
borde.Color = COLOR_APAGADO
borde.Parent = circulo

local punto = Instance.new("Frame")
punto.AnchorPoint = Vector2.new(0.5, 0.5)
punto.Position = UDim2.fromScale(0.5, 0.5)
punto.Size = UDim2.fromOffset(4, 4)
punto.BackgroundColor3 = Color3.new(1, 1, 1)
punto.BorderSizePixel = 0
punto.Parent = gui
Instance.new("UICorner", punto).CornerRadius = UDim.new(1, 0)

local contenedorESP = Instance.new("Folder")
contenedorESP.Name = "MarcasESP"
contenedorESP.Parent = gui

local carpetaLineas = Instance.new("Folder")
carpetaLineas.Name = "LineasJugadores"
carpetaLineas.Parent = gui

local carpetaStuds = Instance.new("Folder")
carpetaStuds.Name = "ContadorStuds"
carpetaStuds.Parent = gui

-- =========================================================
-- NOTIFICACIONES
-- =========================================================
local notifContenedor = Instance.new("Frame")
notifContenedor.AnchorPoint = Vector2.new(1, 0)
notifContenedor.Position = UDim2.new(1, -20, 0, 20)
notifContenedor.Size = UDim2.fromOffset(320, 400)
notifContenedor.BackgroundTransparency = 1
notifContenedor.Parent = gui

local notifLayout = Instance.new("UIListLayout", notifContenedor)
notifLayout.Padding = UDim.new(0, 8)
notifLayout.SortOrder = Enum.SortOrder.LayoutOrder
notifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right

local function notificar(texto, color)
    if not cfg.Notificaciones then return end
    local n = Instance.new("Frame")
    n.Size = UDim2.fromOffset(280, 42)
    n.BackgroundColor3 = T.fondoSuave
    n.BackgroundTransparency = 1
    n.Parent = notifContenedor
    Instance.new("UICorner", n).CornerRadius = UDim.new(0, 12)

    local stripe = Instance.new("Frame")
    stripe.Size = UDim2.new(0, 4, 1, -12)
    stripe.Position = UDim2.fromOffset(6, 6)
    stripe.BackgroundColor3 = color or T.acento
    stripe.BorderSizePixel = 0
    stripe.Parent = n
    Instance.new("UICorner", stripe).CornerRadius = UDim.new(1, 0)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -24, 1, 0)
    lbl.Position = UDim2.fromOffset(18, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = texto
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextColor3 = T.texto
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.TextTransparency = 1
    lbl.Parent = n

    local st = Instance.new("UIStroke", n)
    st.Color = color or T.acento
    st.Transparency = 1
    st.Thickness = 1

    TweenService:Create(n, TweenInfo.new(0.25), { BackgroundTransparency = 0.05 }):Play()
    TweenService:Create(lbl, TweenInfo.new(0.25), { TextTransparency = 0 }):Play()
    TweenService:Create(st, TweenInfo.new(0.25), { Transparency = 0.4 }):Play()

    task.delay(2.5, function()
        TweenService:Create(n, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
        TweenService:Create(lbl, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
        TweenService:Create(st, TweenInfo.new(0.3), { Transparency = 1 }):Play()
        task.wait(0.35)
        if n and n.Parent then n:Destroy() end
    end)
end

-- =========================================================
-- PANEL PRINCIPAL
-- =========================================================
local ANCHO_MIN, ANCHO_MAX = 420, 640
local anchoPanel = 500
local altoPanel = math.clamp(camara.ViewportSize.Y - 120, 360, 660)

local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(anchoPanel, altoPanel)
panel.Position = UDim2.fromOffset(50, 60)
panel.BackgroundColor3 = T.fondo
panel.BorderSizePixel = 0
panel.Active = true
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 16)

local panelBorde = Instance.new("UIStroke")
panelBorde.Thickness = 1.5
panelBorde.Color = T.acento
panelBorde.Transparency = 0.3
panelBorde.Parent = panel

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 56)
header.BackgroundColor3 = T.fondoSuave
header.BorderSizePixel = 0
header.Active = true
header.Parent = panel
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 16)

local headerCover = Instance.new("Frame")
headerCover.Size = UDim2.new(1, 0, 0, 20)
headerCover.Position = UDim2.new(0, 0, 1, -20)
headerCover.BackgroundColor3 = T.fondoSuave
headerCover.BorderSizePixel = 0
headerCover.Parent = header

local puntoAcc = Instance.new("Frame")
puntoAcc.Size = UDim2.fromOffset(8, 8)
puntoAcc.Position = UDim2.fromOffset(16, 24)
puntoAcc.BackgroundColor3 = T.acento
puntoAcc.BorderSizePixel = 0
puntoAcc.Parent = header
Instance.new("UICorner", puntoAcc).CornerRadius = UDim.new(1, 0)

local titulo = Instance.new("TextLabel")
titulo.Size = UDim2.new(1, -180, 0, 22)
titulo.Position = UDim2.fromOffset(34, 10)
titulo.BackgroundTransparency = 1
titulo.Text = "AIM PANEL v23.1"
titulo.TextXAlignment = Enum.TextXAlignment.Left
titulo.TextColor3 = T.texto
titulo.Font = Enum.Font.GothamBold
titulo.TextSize = 17
titulo.Parent = header

local subtitulo = Instance.new("TextLabel")
subtitulo.Size = UDim2.new(1, -180, 0, 14)
subtitulo.Position = UDim2.fromOffset(34, 31)
subtitulo.BackgroundTransparency = 1
subtitulo.Text = "RShift ocultar  •  P panico"
subtitulo.TextXAlignment = Enum.TextXAlignment.Left
subtitulo.TextColor3 = T.sub
subtitulo.Font = Enum.Font.Gotham
subtitulo.TextSize = 10
subtitulo.Parent = header

local buscador = Instance.new("TextBox")
buscador.Size = UDim2.fromOffset(150, 26)
buscador.Position = UDim2.new(1, -250, 0, 15)
buscador.BackgroundColor3 = T.tarjeta2
buscador.Text = ""
buscador.PlaceholderText = "Buscar..."
buscador.TextColor3 = T.texto
buscador.PlaceholderColor3 = T.sub
buscador.Font = Enum.Font.Gotham
buscador.TextSize = 12
buscador.BorderSizePixel = 0
buscador.ClearTextOnFocus = false
buscador.Parent = header
Instance.new("UICorner", buscador).CornerRadius = UDim.new(0, 8)

local btnMin = Instance.new("TextButton")
btnMin.Size = UDim2.fromOffset(28, 28)
btnMin.Position = UDim2.new(1, -76, 0, 14)
btnMin.BackgroundColor3 = T.tarjeta2
btnMin.Text = "−"
btnMin.TextColor3 = T.sub
btnMin.Font = Enum.Font.GothamBold
btnMin.TextSize = 16
btnMin.AutoButtonColor = false
btnMin.Parent = header
Instance.new("UICorner", btnMin).CornerRadius = UDim.new(0, 8)

local btnMax = Instance.new("TextButton")
btnMax.Size = UDim2.fromOffset(28, 28)
btnMax.Position = UDim2.new(1, -42, 0, 14)
btnMax.BackgroundColor3 = T.tarjeta2
btnMax.Text = "□"
btnMax.TextColor3 = T.sub
btnMax.Font = Enum.Font.GothamBold
btnMax.TextSize = 14
btnMax.AutoButtonColor = false
btnMax.Parent = header
Instance.new("UICorner", btnMax).CornerRadius = UDim.new(0, 8)

for _, b in { btnMin, btnMax } do
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), { BackgroundColor3 = T.acento }):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), { BackgroundColor3 = T.tarjeta2 }):Play()
    end)
end

do
    local arrastrando, inicioMouse, inicioPos
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            arrastrando = true
            inicioMouse = input.Position
            inicioPos = panel.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if arrastrando and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - inicioMouse
            panel.Position = UDim2.new(
                inicioPos.X.Scale, inicioPos.X.Offset + d.X,
                inicioPos.Y.Scale, inicioPos.Y.Offset + d.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            arrastrando = false
        end
    end)
end

-- TABS
local tabsFrame = Instance.new("Frame")
tabsFrame.Position = UDim2.fromOffset(0, 56)
tabsFrame.Size = UDim2.new(0, 130, 1, -56)
tabsFrame.BackgroundColor3 = T.fondoSuave
tabsFrame.BorderSizePixel = 0
tabsFrame.Parent = panel

local tabsLayout = Instance.new("UIListLayout", tabsFrame)
tabsLayout.Padding = UDim.new(0, 4)
tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local tabsPad = Instance.new("UIPadding", tabsFrame)
tabsPad.PaddingTop = UDim.new(0, 10)

local contenidoFrame = Instance.new("Frame")
contenidoFrame.Position = UDim2.fromOffset(130, 56)
contenidoFrame.Size = UDim2.new(1, -130, 1, -56)
contenidoFrame.BackgroundTransparency = 1
contenidoFrame.Parent = panel

local paginas = {}
local botonesTab = {}
local tabActual = nil
local todasLasFilas = {}

local function crearTab(nombre, icono)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -16, 0, 36)
    b.BackgroundColor3 = T.tarjeta
    b.BackgroundTransparency = 0.4
    b.Text = ""
    b.AutoButtonColor = false
    b.LayoutOrder = #botonesTab + 1
    b.Parent = tabsFrame
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)

    local ind = Instance.new("Frame")
    ind.Size = UDim2.new(0, 3, 0, 0)
    ind.Position = UDim2.new(0, 0, 0.5, 0)
    ind.AnchorPoint = Vector2.new(0, 0.5)
    ind.BackgroundColor3 = T.acento
    ind.BorderSizePixel = 0
    ind.Parent = b
    Instance.new("UICorner", ind).CornerRadius = UDim.new(1, 0)

    local ico = Instance.new("TextLabel")
    ico.Size = UDim2.fromOffset(22, 36)
    ico.Position = UDim2.fromOffset(10, 0)
    ico.BackgroundTransparency = 1
    ico.Text = icono
    ico.TextColor3 = T.sub
    ico.Font = Enum.Font.GothamBold
    ico.TextSize = 14
    ico.Parent = b

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -34, 1, 0)
    lbl.Position = UDim2.fromOffset(34, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = nombre
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextColor3 = T.sub
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 12
    lbl.Parent = b

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.ScrollingDirection = Enum.ScrollingDirection.Y
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = T.acento
    page.Visible = false
    page.Parent = contenidoFrame

    local pl = Instance.new("UIListLayout", page)
    pl.Padding = UDim.new(0, 6)
    pl.SortOrder = Enum.SortOrder.LayoutOrder
    pl.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local pp = Instance.new("UIPadding", page)
    pp.PaddingTop = UDim.new(0, 12)
    pp.PaddingBottom = UDim.new(0, 16)
    pp.PaddingLeft = UDim.new(0, 12)
    pp.PaddingRight = UDim.new(0, 12)

    paginas[nombre] = page
    botonesTab[nombre] = { boton = b, ind = ind, ico = ico, lbl = lbl }

    b.MouseEnter:Connect(function()
        if tabActual ~= nombre then
            TweenService:Create(b, TweenInfo.new(0.15), { BackgroundTransparency = 0.2 }):Play()
        end
    end)
    b.MouseLeave:Connect(function()
        if tabActual ~= nombre then
            TweenService:Create(b, TweenInfo.new(0.15), { BackgroundTransparency = 0.4 }):Play()
        end
    end)

    b.MouseButton1Click:Connect(function()
        sonarUI("click")
        for n, d in pairs(botonesTab) do
            paginas[n].Visible = false
            TweenService:Create(d.boton, TweenInfo.new(0.2), { BackgroundColor3 = T.tarjeta, BackgroundTransparency = 0.4 }):Play()
            TweenService:Create(d.ind, TweenInfo.new(0.2), { Size = UDim2.new(0, 3, 0, 0) }):Play()
            TweenService:Create(d.lbl, TweenInfo.new(0.2), { TextColor3 = T.sub }):Play()
            TweenService:Create(d.ico, TweenInfo.new(0.2), { TextColor3 = T.sub }):Play()
        end
        tabActual = nombre
        paginas[nombre].Visible = true
        TweenService:Create(b, TweenInfo.new(0.2), { BackgroundColor3 = T.acento, BackgroundTransparency = 0.85 }):Play()
        TweenService:Create(ind, TweenInfo.new(0.2), { Size = UDim2.new(0, 3, 0, 20) }):Play()
        TweenService:Create(lbl, TweenInfo.new(0.2), { TextColor3 = T.texto }):Play()
        TweenService:Create(ico, TweenInfo.new(0.2), { TextColor3 = T.acento }):Play()
    end)

    return page
end

local function aplicarTema(idx)
    cfg.TemaActual = idx
    local t = TEMAS[idx]
    if cfg.UsarColorCustom then
        T.acento  = cfg.ColorCustom
        T.acento2 = cfg.ColorCustom:Lerp(Color3.new(1, 1, 1), 0.4)
    else
        T.acento  = t.acento
        T.acento2 = t.acento2
        T.fondo   = t.fondo
        T.fondoSuave = t.fondo:Lerp(Color3.new(1, 1, 1), 0.05)
    end
    panel.BackgroundColor3 = T.fondo
    header.BackgroundColor3 = T.fondoSuave
    headerCover.BackgroundColor3 = T.fondoSuave
    tabsFrame.BackgroundColor3 = T.fondoSuave
    panelBorde.Color = T.acento
    puntoAcc.BackgroundColor3 = T.acento
end

aplicarTema(cfg.TemaActual)

-- =========================================================
-- WIDGETS
-- =========================================================
local orden = 1
local refrescadores = {}
local contenedorActual = nil

local function setContenedor(page)
    contenedorActual = page
    orden = 1
end

local tooltip = Instance.new("TextLabel")
tooltip.AnchorPoint = Vector2.new(0, 0)
tooltip.Size = UDim2.fromOffset(220, 28)
tooltip.BackgroundColor3 = T.tarjeta2
tooltip.BackgroundTransparency = 0.05
tooltip.TextColor3 = T.texto
tooltip.Font = Enum.Font.Gotham
tooltip.TextSize = 11
tooltip.TextWrapped = true
tooltip.Visible = false
tooltip.ZIndex = 100
tooltip.Parent = gui
Instance.new("UICorner", tooltip).CornerRadius = UDim.new(0, 6)
local ttStroke = Instance.new("UIStroke", tooltip)
ttStroke.Color = T.acento
ttStroke.Thickness = 1
ttStroke.Transparency = 0.3

local function attachTooltip(fila, texto)
    fila.MouseEnter:Connect(function()
        tooltip.Text = texto
        local m = UserInputService:GetMouseLocation()
        tooltip.Position = UDim2.fromOffset(m.X + 15, m.Y + 10)
        tooltip.Visible = true
    end)
    fila.MouseLeave:Connect(function()
        tooltip.Visible = false
    end)
end

local function registrarFila(fila, texto)
    table.insert(todasLasFilas, { fila = fila, texto = string.lower(texto), page = contenedorActual })
end

local function crearToggle(texto, clave, tecla, tooltipTxt)
    local fila = Instance.new("TextButton")
    fila.Size = UDim2.new(1, 0, 0, 40)
    fila.BackgroundColor3 = T.tarjeta
    fila.BackgroundTransparency = 0.2
    fila.AutoButtonColor = false
    fila.Text = ""
    fila.LayoutOrder = orden
    orden += 1
    fila.Parent = contenedorActual
    Instance.new("UICorner", fila).CornerRadius = UDim.new(0, 10)

    local st = Instance.new("UIStroke", fila)
    st.Color = T.tarjeta2
    st.Thickness = 1
    st.Transparency = 0.5

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -120, 1, 0)
    lbl.Position = UDim2.fromOffset(14, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = texto
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextColor3 = T.texto
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.Parent = fila

    if tecla then
        local badge = Instance.new("TextLabel")
        badge.AnchorPoint = Vector2.new(1, 0.5)
        badge.Size = UDim2.fromOffset(26, 18)
        badge.Position = UDim2.new(1, -62, 0.5, 0)
        badge.BackgroundColor3 = T.tarjeta2
        badge.Text = tecla
        badge.TextColor3 = T.sub
        badge.Font = Enum.Font.GothamBold
        badge.TextSize = 10
        badge.Parent = fila
        Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 5)
    end

    local pista = Instance.new("Frame")
    pista.AnchorPoint = Vector2.new(1, 0.5)
    pista.Size = UDim2.fromOffset(42, 22)
    pista.Position = UDim2.new(1, -14, 0.5, 0)
    pista.BackgroundColor3 = T.off
    pista.Parent = fila
    Instance.new("UICorner", pista).CornerRadius = UDim.new(1, 0)

    local perilla = Instance.new("Frame")
    perilla.AnchorPoint = Vector2.new(0, 0.5)
    perilla.Size = UDim2.fromOffset(18, 18)
    perilla.Position = UDim2.new(0, 2, 0.5, 0)
    perilla.BackgroundColor3 = Color3.new(1, 1, 1)
    perilla.Parent = pista
    Instance.new("UICorner", perilla).CornerRadius = UDim.new(1, 0)

    local info = TweenInfo.new(0.18, Enum.EasingStyle.Quad)
    local function refrescar()
        local on = cfg[clave]
        TweenService:Create(pista, info, { BackgroundColor3 = on and T.on or T.off }):Play()
        TweenService:Create(perilla, info, {
            Position = on and UDim2.new(0, 22, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
        }):Play()
        TweenService:Create(st, info, { Color = on and T.on or T.tarjeta2, Transparency = on and 0 or 0.5 }):Play()
    end
    refrescadores[clave] = refrescar
    fila.MouseButton1Click:Connect(function()
        cfg[clave] = not cfg[clave]
        sonarUI("click")
        refrescar()
        guardarConfig()
    end)
    fila.MouseEnter:Connect(function()
        TweenService:Create(fila, info, { BackgroundColor3 = T.tarjeta2 }):Play()
    end)
    fila.MouseLeave:Connect(function()
        TweenService:Create(fila, info, { BackgroundColor3 = T.tarjeta, BackgroundTransparency = 0.2 }):Play()
    end)
    refrescar()
    registrarFila(fila, texto)
    if tooltipTxt then attachTooltip(fila, tooltipTxt) end
end

local function crearStepper(texto, clave, paso, minimo, maximo, formato, tooltipTxt)
    local fila = Instance.new("Frame")
    fila.Size = UDim2.new(1, 0, 0, 40)
    fila.BackgroundColor3 = T.tarjeta
    fila.BackgroundTransparency = 0.2
    fila.LayoutOrder = orden
    orden += 1
    fila.Parent = contenedorActual
    Instance.new("UICorner", fila).CornerRadius = UDim.new(0, 10)

    local st = Instance.new("UIStroke", fila)
    st.Color = T.tarjeta2
    st.Thickness = 1
    st.Transparency = 0.5

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -170, 1, 0)
    lbl.Position = UDim2.fromOffset(14, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = texto
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextColor3 = T.texto
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.Parent = fila

    local caja = Instance.new("Frame")
    caja.AnchorPoint = Vector2.new(1, 0.5)
    caja.Size = UDim2.fromOffset(140, 28)
    caja.Position = UDim2.new(1, -14, 0.5, 0)
    caja.BackgroundColor3 = T.fondoSuave
    caja.Parent = fila
    Instance.new("UICorner", caja).CornerRadius = UDim.new(0, 8)

    local valor = Instance.new("TextLabel")
    valor.Size = UDim2.new(1, -56, 1, 0)
    valor.Position = UDim2.fromOffset(8, 0)
    valor.BackgroundTransparency = 1
    valor.TextColor3 = T.texto
    valor.Font = Enum.Font.GothamBold
    valor.TextSize = 13
    valor.TextXAlignment = Enum.TextXAlignment.Left
    valor.Parent = caja

    local function refrescar()
        valor.Text = string.format(formato, cfg[clave])
    end

    local function boton(txt, lado)
        local b = Instance.new("TextButton")
        b.AnchorPoint = Vector2.new(1, 0.5)
        b.Size = UDim2.fromOffset(24, 24)
        b.Position = UDim2.new(1, lado == "mas" and -2 or -28, 0.5, 0)
        b.BackgroundColor3 = T.tarjeta2
        b.Text = txt
        b.TextColor3 = T.texto
        b.Font = Enum.Font.GothamBold
        b.TextSize = 15
        b.AutoButtonColor = false
        b.Parent = caja
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        b.MouseButton1Click:Connect(function()
            local delta = lado == "mas" and paso or -paso
            cfg[clave] = math.clamp(cfg[clave] + delta, minimo, maximo)
            sonarUI("click")
            refrescar()
            guardarConfig()
        end)
        b.MouseEnter:Connect(function()
            TweenService:Create(b, TweenInfo.new(0.15), { BackgroundColor3 = T.acento }):Play()
        end)
        b.MouseLeave:Connect(function()
            TweenService:Create(b, TweenInfo.new(0.15), { BackgroundColor3 = T.tarjeta2 }):Play()
        end)
    end
    boton("−", "menos")
    boton("+", "mas")

    refrescar()
    registrarFila(fila, texto)
    if tooltipTxt then attachTooltip(fila, tooltipTxt) end
end

local function crearSelector(texto, clave, opciones, alCambiar, tooltipTxt)
    local fila = Instance.new("TextButton")
    fila.Size = UDim2.new(1, 0, 0, 40)
    fila.BackgroundColor3 = T.tarjeta
    fila.BackgroundTransparency = 0.2
    fila.AutoButtonColor = false
    fila.Text = ""
    fila.LayoutOrder = orden
    orden += 1
    fila.Parent = contenedorActual
    Instance.new("UICorner", fila).CornerRadius = UDim.new(0, 10)

    local st = Instance.new("UIStroke", fila)
    st.Color = T.tarjeta2
    st.Thickness = 1
    st.Transparency = 0.5

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -160, 1, 0)
    lbl.Position = UDim2.fromOffset(14, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = texto
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextColor3 = T.texto
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.Parent = fila

    local valor = Instance.new("Frame")
    valor.AnchorPoint = Vector2.new(1, 0.5)
    valor.Size = UDim2.fromOffset(120, 26)
    valor.Position = UDim2.new(1, -14, 0.5, 0)
    valor.BackgroundColor3 = T.acento
    valor.BackgroundTransparency = 0.85
    valor.Parent = fila
    Instance.new("UICorner", valor).CornerRadius = UDim.new(0, 8)

    local valorLbl = Instance.new("TextLabel")
    valorLbl.Size = UDim2.fromScale(1, 1)
    valorLbl.BackgroundTransparency = 1
    valorLbl.TextColor3 = T.acento2
    valorLbl.Font = Enum.Font.GothamBold
    valorLbl.TextSize = 12
    valorLbl.Parent = valor

    local function refrescar()
        local idx = cfg[clave]
        if type(idx) ~= "number" or idx < 1 or idx > #opciones then
            idx = 1
            cfg[clave] = 1
        end
        valorLbl.Text = opciones[idx] or "?"
    end
    fila.MouseButton1Click:Connect(function()
        cfg[clave] = cfg[clave] % #opciones + 1
        sonarUI("click")
        refrescar()
        if alCambiar then alCambiar(cfg[clave]) end
        guardarConfig()
    end)
    local info = TweenInfo.new(0.15)
    fila.MouseEnter:Connect(function()
        TweenService:Create(fila, info, { BackgroundColor3 = T.tarjeta2 }):Play()
    end)
    fila.MouseLeave:Connect(function()
        TweenService:Create(fila, info, { BackgroundColor3 = T.tarjeta }):Play()
    end)
    refrescar()
    registrarFila(fila, texto)
    if tooltipTxt then attachTooltip(fila, tooltipTxt) end
end

local function crearKeybind(texto, clave, tooltipTxt)
    local fila = Instance.new("TextButton")
    fila.Size = UDim2.new(1, 0, 0, 40)
    fila.BackgroundColor3 = T.tarjeta
    fila.BackgroundTransparency = 0.2
    fila.AutoButtonColor = false
    fila.Text = ""
    fila.LayoutOrder = orden
    orden += 1
    fila.Parent = contenedorActual
    Instance.new("UICorner", fila).CornerRadius = UDim.new(0, 10)

    local st = Instance.new("UIStroke", fila)
    st.Color = T.tarjeta2
    st.Thickness = 1
    st.Transparency = 0.5

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -160, 1, 0)
    lbl.Position = UDim2.fromOffset(14, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = texto
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextColor3 = T.texto
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.Parent = fila

    local valor = Instance.new("Frame")
    valor.AnchorPoint = Vector2.new(1, 0.5)
    valor.Size = UDim2.fromOffset(120, 26)
    valor.Position = UDim2.new(1, -14, 0.5, 0)
    valor.BackgroundColor3 = T.acento
    valor.BackgroundTransparency = 0.85
    valor.Parent = fila
    Instance.new("UICorner", valor).CornerRadius = UDim.new(0, 8)

    local valorLbl = Instance.new("TextLabel")
    valorLbl.Size = UDim2.fromScale(1, 1)
    valorLbl.BackgroundTransparency = 1
    valorLbl.TextColor3 = T.acento2
    valorLbl.Font = Enum.Font.GothamBold
    valorLbl.TextSize = 12
    valorLbl.Text = cfg[clave].Name
    valorLbl.Parent = valor

    local esperando = false
    fila.MouseButton1Click:Connect(function()
        if esperando then return end
        esperando = true
        valorLbl.Text = "..."
        valor.BackgroundColor3 = T.amarillo
        local conn
        conn = UserInputService.InputBegan:Connect(function(input, proc)
            if proc then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                cfg[clave] = input.KeyCode
                valorLbl.Text = input.KeyCode.Name
                valor.BackgroundColor3 = T.acento
                esperando = false
                conn:Disconnect()
                guardarConfig()
            end
        end)
    end)
    registrarFila(fila, texto)
    if tooltipTxt then attachTooltip(fila, tooltipTxt) end
end

local function crearBoton(texto, color, alClick, tooltipTxt)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 36)
    b.BackgroundColor3 = color
    b.BackgroundTransparency = 0.15
    b.AutoButtonColor = false
    b.Text = texto
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.LayoutOrder = orden
    orden += 1
    b.Parent = contenedorActual
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
    local st = Instance.new("UIStroke", b)
    st.Color = color
    st.Thickness = 1
    st.Transparency = 0.5
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), { BackgroundTransparency = 0 }):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), { BackgroundTransparency = 0.15 }):Play()
    end)
    b.MouseButton1Click:Connect(function()
        sonarUI("click")
        alClick()
    end)
    if tooltipTxt then attachTooltip(b, tooltipTxt) end
    return b
end

-- =========================================================
-- COLOR PICKER
-- =========================================================
local IMG_RUEDA = "rbxassetid://137983631090429"

local function crearColorPicker(clave)
    local fila = Instance.new("Frame")
    fila.Size = UDim2.new(1, 0, 0, 250)
    fila.BackgroundColor3 = T.tarjeta
    fila.BackgroundTransparency = 0.2
    fila.LayoutOrder = orden
    orden += 1
    fila.Parent = contenedorActual
    Instance.new("UICorner", fila).CornerRadius = UDim.new(0, 10)

    local lbl = Instance.new("TextLabel")
    lbl.Position = UDim2.fromOffset(14, 10)
    lbl.Size = UDim2.new(1, -28, 0, 16)
    lbl.BackgroundTransparency = 1
    lbl.Text = "Rueda de color"
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextColor3 = T.texto
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.Parent = fila

    local rueda = Instance.new("ImageButton")
    rueda.AnchorPoint = Vector2.new(0.5, 0)
    rueda.Position = UDim2.new(0.5, 0, 0, 32)
    rueda.Size = UDim2.fromOffset(180, 180)
    rueda.BackgroundTransparency = 1
    rueda.Image = IMG_RUEDA
    rueda.ScaleType = Enum.ScaleType.Fit
    rueda.AutoButtonColor = false
    rueda.Active = true
    rueda.Parent = fila
    Instance.new("UICorner", rueda).CornerRadius = UDim.new(1, 0)

    local selector = Instance.new("Frame")
    selector.AnchorPoint = Vector2.new(0.5, 0.5)
    selector.Size = UDim2.fromOffset(18, 18)
    selector.BackgroundColor3 = Color3.new(1, 1, 1)
    selector.BorderSizePixel = 0
    selector.ZIndex = 10
    selector.Visible = false
    selector.Parent = rueda
    Instance.new("UICorner", selector).CornerRadius = UDim.new(1, 0)
    local selBorde = Instance.new("UIStroke", selector)
    selBorde.Color = Color3.new(0, 0, 0)
    selBorde.Thickness = 2

    local preview = Instance.new("Frame")
    preview.AnchorPoint = Vector2.new(0.5, 0)
    preview.Position = UDim2.new(0.5, 0, 0, 218)
    preview.Size = UDim2.fromOffset(180, 24)
    preview.BackgroundColor3 = cfg[clave]
    preview.BorderSizePixel = 0
    preview.Parent = fila
    Instance.new("UICorner", preview).CornerRadius = UDim.new(0, 6)
    local pvBorde = Instance.new("UIStroke", preview)
    pvBorde.Color = Color3.new(1, 1, 1)
    pvBorde.Transparency = 0.4
    pvBorde.Thickness = 1

    local arrastrando = false

    local function actualizarDesdePosicion(mousePos)
        local absPos = rueda.AbsolutePosition
        local absSize = rueda.AbsoluteSize
        local cx = absPos.X + absSize.X / 2
        local cy = absPos.Y + absSize.Y / 2
        local radio = absSize.X / 2
        local dx = mousePos.X - cx
        local dy = mousePos.Y - cy
        local dist = math.sqrt(dx*dx + dy*dy)
        if dist > radio then
            if dist > 0 then
                dx = (dx / dist) * radio
                dy = (dy / dist) * radio
            end
            dist = radio
        end
        local ang = math.atan2(dy, dx)
        local hue = (ang / (math.pi * 2) + 0.75) % 1
        local sat = math.clamp(dist / radio, 0, 1)
        local color = Color3.fromHSV(hue, sat, 1)
        selector.Position = UDim2.fromOffset(absSize.X / 2 + dx, absSize.Y / 2 + dy)
        selector.BackgroundColor3 = color
        selector.Visible = true
        preview.BackgroundColor3 = color
        cfg[clave] = color
        cfg.UsarColorCustom = true
        T.acento = color
        T.acento2 = color:Lerp(Color3.new(1, 1, 1), 0.4)
        panelBorde.Color = T.acento
        puntoAcc.BackgroundColor3 = T.acento
    end

    rueda.MouseButton1Down:Connect(function()
        arrastrando = true
        actualizarDesdePosicion(UserInputService:GetMouseLocation())
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not arrastrando then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            actualizarDesdePosicion(UserInputService:GetMouseLocation())
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            if arrastrando then
                arrastrando = false
                guardarConfig()
            end
        end
    end)
end

-- =========================================================
-- CREAR TABS
-- =========================================================
local tabCombate     = crearTab("Combate", "⚔")
local tabTrigger     = crearTab("Trigger", "🎯")
local tabAntiAim     = crearTab("Anti-Aim", "🌀")
local tabTrayectoria = crearTab("Trayectoria", "🔫")
local tabVisual      = crearTab("Visual", "👁")
local tabStuds       = crearTab("Studs", "📏")
local tabPunteria    = crearTab("Puntería", "⊕")
local tabPrediccion  = crearTab("Predicción", "⏱")
local tabProteccion  = crearTab("Protección", "🛡")
local tabSonido      = crearTab("Sonido", "🔊")
local tabKills       = crearTab("Kills", "💀")
local tabHUD         = crearTab("HUD", "📊")
local tabAjustes     = crearTab("Ajustes", "⚙")
local tabTemas       = crearTab("Temas", "🎨")
local tabTeclas      = crearTab("Teclas", "⌨")
local tabPerfiles    = crearTab("Perfiles", "💾")

-- COMBATE
setContenedor(tabCombate)
crearToggle("Aimbot", "Aimbot", "E", "Activa/desactiva el aimbot")
crearToggle("Solo con click der.", "SoloClickDerecho", nil, "Solo apunta al mantener click derecho")
crearToggle("Trabar objetivo", "TrabarObjetivo", nil, "Mantiene el mismo objetivo hasta que muera")
crearToggle("Priorizar amenaza", "PriorizarAmenaza", nil, "Prioriza al enemigo que te apunta")
crearToggle("Priorizar mas cercano", "PriorizarCercano", nil, "Apunta al enemigo más cercano")
crearToggle("Priorizar poca vida", "PriorizarPocaVida", nil, "Apunta al enemigo con menos HP")
crearToggle("Priorizar cabeza", "PriorizarCabeza", nil, "Apunta a la cabeza si es visible")
crearToggle("Aim al más cercano al cursor", "AimCercanoCursor", nil, "Prioriza el hueso más cercano al cursor")
crearToggle("FOV dinamico", "FovDinamico", nil, "Reduce el FOV cuando hay objetivo")
crearToggle("FOV por distancia", "FovPorDistancia", nil, "FOV más chico al estar lejos")
crearToggle("Anti-shake", "AntiShake", nil, "Reduce micro-movimientos bruscos")
crearStepper("Anti-shake fuerza", "AntiShakeForce", 0.05, 0.01, 0.5, "%.2f", "Cuánto reducir el shake")
crearStepper("FOV minimo", "FovMinimo", 10, 20, 300, "%d", "FOV mínimo cuando el dinámico está activo")
crearStepper("Radio FOV", "FovRadio", 20, 40, 500, "%d", "Radio de detección del aimbot")
crearStepper("FOV max distancia", "FovPorDistanciaMax", 100, 100, 5000, "%d", "Distancia máxima del FOV por distancia")
crearStepper("Suavidad", "Suavidad", 5, 1, 100, "%d", "Cuánto tarda en apuntar (más alto = más rápido)")
crearSelector("Curva suavizado", "CurvaSuavizado", {"Lineal","Quad","Sine","Expo"}, nil, "Curva de interpolación")
crearStepper("Restricción ángulo", "AimRestriccion", 5, 5, 180, "%d", "Grados máximos de giro por frame")
crearStepper("Distancia aimbot", "Rango3D", 100, 200, 5000, "%d", "Distancia máxima en 3D")
crearStepper("Distancia disparo", "DistanciaDisparo", 100, 200, 5000, "%d", "Para detectar kills")
crearToggle("Ignorar mi equipo", "IgnorarEquipo", nil, "No apunta a aliados")
crearToggle("Wall check", "VerificarParedes", nil, "Solo apunta si hay línea de visión")
crearToggle("Auto-fire (mantener tecla)", "AutoFireHold", nil, "Dispara al mantener la tecla")
crearStepper("Auto-fire delay (ms)", "AutoFireMs", 20, 20, 500, "%d", "Delay entre disparos del autofire")

-- TRIGGER
setContenedor(tabTrigger)
crearToggle("Triggerbot activo", "Triggerbot", nil, "Dispara automáticamente al apuntar a un enemigo")
crearStepper("Delay (ms)", "TriggerDelay", 10, 0, 500, "%d", "Tiempo entre disparos")
crearStepper("Rango", "TriggerRango", 50, 50, 1000, "%d", "Distancia máxima del raycast")
crearStepper("Ráfaga (disparos)", "TriggerRafaga", 1, 1, 10, "%d", "Disparos por ráfaga")
crearStepper("Ráfaga delay (ms)", "TriggerRafagaMs", 10, 20, 500, "%d", "Delay entre disparos de ráfaga")

-- ANTI-AIM
setContenedor(tabAntiAim)
crearToggle("Anti-aim activo", "AntiAim", "X", "Gira tu personaje para confundir aimbots")
crearSelector("Modo", "AntiAimModo", { "Spin", "Jitter", "Fake Backwards" }, nil, "Tipo de rotación")
crearStepper("Velocidad", "AntiAimVel", 100, 100, 3000, "%d", "Velocidad de rotación")

-- =========================================================
-- TRAYECTORIA
-- =========================================================
setContenedor(tabTrayectoria)

local infoTray = Instance.new("Frame")
infoTray.Size = UDim2.new(1, 0, 0, 50)
infoTray.BackgroundColor3 = T.tarjeta
infoTray.BackgroundTransparency = 0.2
infoTray.LayoutOrder = orden
orden += 1
infoTray.Parent = tabTrayectoria
Instance.new("UICorner", infoTray).CornerRadius = UDim.new(0, 10)

local infoLbl = Instance.new("TextLabel")
infoLbl.Size = UDim2.new(1, -20, 1, 0)
infoLbl.Position = UDim2.fromOffset(10, 0)
infoLbl.BackgroundTransparency = 1
infoLbl.Text = "Programa hacia dónde va cada bala.\nSelecciona un slot abajo y toca una parte del cuerpo."
infoLbl.TextXAlignment = Enum.TextXAlignment.Left
infoLbl.TextColor3 = T.sub
infoLbl.Font = Enum.Font.Gotham
infoLbl.TextSize = 11
infoLbl.TextWrapped = true
infoLbl.Parent = infoTray

crearToggle("Usar trayectoria programada", "UsarTrayectoria", nil, "Activa el sistema de balas programables")
crearToggle("Loop (volver al inicio)", "TrayectoriaLoop", nil, "Al terminar las 10 balas, vuelve a la 1")

local txtSlotActivo = Instance.new("TextLabel")
txtSlotActivo.Size = UDim2.new(1, 0, 0, 30)
txtSlotActivo.BackgroundColor3 = T.acento
txtSlotActivo.BackgroundTransparency = 0.85
txtSlotActivo.Text = "Editando: BALA 1"
txtSlotActivo.TextColor3 = T.acento2
txtSlotActivo.Font = Enum.Font.GothamBold
txtSlotActivo.TextSize = 14
txtSlotActivo.LayoutOrder = orden
orden += 1
txtSlotActivo.Parent = tabTrayectoria
Instance.new("UICorner", txtSlotActivo).CornerRadius = UDim.new(0, 10)

local txtProgreso = Instance.new("TextLabel")
txtProgreso.Size = UDim2.new(1, 0, 0, 26)
txtProgreso.BackgroundColor3 = T.tarjeta
txtProgreso.BackgroundTransparency = 0.2
txtProgreso.Text = "Progreso: BALA 1 de 10"
txtProgreso.TextColor3 = T.sub
txtProgreso.Font = Enum.Font.Gotham
txtProgreso.TextSize = 12
txtProgreso.LayoutOrder = orden
orden += 1
txtProgreso.Parent = tabTrayectoria
Instance.new("UICorner", txtProgreso).CornerRadius = UDim.new(0, 10)

local gridSlots = Instance.new("Frame")
gridSlots.Size = UDim2.new(1, 0, 0, 80)
gridSlots.BackgroundColor3 = T.tarjeta
gridSlots.BackgroundTransparency = 0.2
gridSlots.LayoutOrder = orden
orden += 1
gridSlots.Parent = tabTrayectoria
Instance.new("UICorner", gridSlots).CornerRadius = UDim.new(0, 10)

local gridLayout = Instance.new("UIGridLayout", gridSlots)
gridLayout.CellSize = UDim2.fromOffset(48, 30)
gridLayout.CellPadding = UDim2.fromOffset(6, 6)
gridLayout.SortOrder = Enum.SortOrder.LayoutOrder

local btnSlots = {}
local NOMBRE_CORTO = {
    Head = "Cab", Torso = "Tor", RightArm = "BD", LeftArm = "BI",
    RightLeg = "PD", LeftLeg = "PI", Auto = "Auto",
}

local function refrescarSlots()
    for i = 1, 10 do
        local b = btnSlots[i]
        if b then
            local parte = cfg.TrayectoriaSlots[i] or "Head"
            b.Text = i .. ": " .. (NOMBRE_CORTO[parte] or parte)
            if cfg._SlotSeleccionado == i then
                b.BackgroundColor3 = T.acento
            else
                b.BackgroundColor3 = T.tarjeta2
            end
            if cfg._TrayectoriaIdx == i then
                b.TextColor3 = T.amarillo
            else
                b.TextColor3 = T.texto
            end
        end
    end
    txtSlotActivo.Text = "Editando: BALA " .. cfg._SlotSeleccionado
    txtProgreso.Text = "Progreso: BALA " .. cfg._TrayectoriaIdx .. " de 10"
end

local refrescadorSlots = refrescarSlots -- FIX: Declarada con local

for i = 1, 10 do
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(48, 30)
    b.BackgroundColor3 = T.tarjeta2
    b.Text = i .. ": Cab"
    b.TextColor3 = T.texto
    b.Font = Enum.Font.GothamBold
    b.TextSize = 10
    b.AutoButtonColor = false
    b.LayoutOrder = i
    b.Parent = gridSlots
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    btnSlots[i] = b

    b.MouseButton1Click:Connect(function()
        cfg._SlotSeleccionado = i
        sonarUI("click")
        refrescarSlots()
    end)
end

refrescarSlots()

local tarjetaCuerpo = Instance.new("Frame")
tarjetaCuerpo.Size = UDim2.new(1, 0, 0, 206)
tarjetaCuerpo.BackgroundColor3 = T.tarjeta
tarjetaCuerpo.BackgroundTransparency = 0.2
tarjetaCuerpo.LayoutOrder = orden
orden += 1
tarjetaCuerpo.Parent = tabTrayectoria
Instance.new("UICorner", tarjetaCuerpo).CornerRadius = UDim.new(0, 10)

local PARTES_UI = {
    { clave = "Head",     nombre = "Cabeza",     pos = Vector2.new(51, 30),  tam = Vector2.new(34, 34), color = Color3.fromRGB(245, 205, 48) },
    { clave = "Torso",    nombre = "Torso",      pos = Vector2.new(40, 66),  tam = Vector2.new(56, 62), color = Color3.fromRGB(13, 105, 172) },
    { clave = "RightArm", nombre = "Brazo der.", pos = Vector2.new(12, 66),  tam = Vector2.new(26, 62), color = Color3.fromRGB(245, 205, 48) },
    { clave = "LeftArm",  nombre = "Brazo izq.", pos = Vector2.new(98, 66),  tam = Vector2.new(26, 62), color = Color3.fromRGB(245, 205, 48) },
    { clave = "RightLeg", nombre = "Pierna der.", pos = Vector2.new(40, 130), tam = Vector2.new(27, 62), color = Color3.fromRGB(40, 127, 71) },
    { clave = "LeftLeg",  nombre = "Pierna izq.", pos = Vector2.new(69, 130), tam = Vector2.new(27, 62), color = Color3.fromRGB(40, 127, 71) },
}

for _, p in PARTES_UI do
    local b = Instance.new("TextButton")
    b.Position = UDim2.fromOffset(p.pos.X, p.pos.Y)
    b.Size = UDim2.fromOffset(p.tam.X, p.tam.Y)
    b.BackgroundColor3 = p.color
    b.AutoButtonColor = false
    b.Text = ""
    b.BorderSizePixel = 0
    b.Parent = tarjetaCuerpo
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)

    b.MouseEnter:Connect(function()
        b.BackgroundColor3 = p.color:Lerp(Color3.new(1, 1, 1), 0.25)
    end)
    b.MouseLeave:Connect(function()
        b.BackgroundColor3 = p.color
    end)
    b.MouseButton1Click:Connect(function()
        cfg.TrayectoriaSlots[cfg._SlotSeleccionado] = p.clave
        sonarUI("click")
        refrescarSlots()
        guardarConfig()
        notificar("BALA " .. cfg._SlotSeleccionado .. " → " .. p.nombre, T.acento)
    end)
end

for _, x in { 9, 21 } do
    local ojo = Instance.new("Frame")
    ojo.Size = UDim2.fromOffset(4, 5)
    ojo.Position = UDim2.fromOffset(x, 12)
    ojo.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    ojo.BorderSizePixel = 0
    ojo.Parent = tarjetaCuerpo
end

crearBoton("Reiniciar progreso (vuelve a bala 1)", T.acento2, function()
    cfg._TrayectoriaIdx = 1
    refrescarSlots()
end)

crearBoton("Reiniciar TODA la trayectoria", T.rojo, function()
    for i = 1, 10 do
        cfg.TrayectoriaSlots[i] = "Head"
    end
    cfg._TrayectoriaIdx = 1
    cfg._SlotSeleccionado = 1
    refrescarSlots()
    guardarConfig()
    notificar("Trayectoria reiniciada", T.rojo)
end)

crearBoton("Poner todo a CABEZA", T.acento, function()
    for i = 1, 10 do
        cfg.TrayectoriaSlots[i] = "Head"
    end
    refrescarSlots()
    guardarConfig()
    notificar("Todo a Cabeza", T.acento)
end)

crearBoton("Poner todo a TORSO", T.acento, function()
    for i = 1, 10 do
        cfg.TrayectoriaSlots[i] = "Torso"
    end
    refrescarSlots()
    guardarConfig()
    notificar("Todo a Torso", T.acento)
end)

-- VISUAL
setContenedor(tabVisual)
crearToggle("ESP jugadores", "ESP", "V", "Muestra información de enemigos")
crearToggle("ESP barra de vida", "ESPVida", nil, "Barra de HP encima")
crearToggle("ESP arma", "ESPArma", nil, "Muestra el arma equipada")
crearToggle("ESP Box 2D", "ESPBox", nil, "Caja alrededor del enemigo")
crearToggle("ESP Skeleton", "ESPSkeleton", nil, "Líneas entre huesos")
crearToggle("Indicadores off-screen", "OffScreenInd", nil, "Flechas al borde indicando enemigos")
crearToggle("Mostrar circulo FOV", "MostrarFOV", nil, "Dibuja el círculo del FOV")
crearToggle("Hitbox jugador", "HitboxJugador", nil, "Caja de selección sobre el modelo")
crearToggle("Chams (highlight)", "Chams", nil, "Resalta al enemigo a través de paredes")
crearToggle("Detectar aimbots", "DetectarAimbots", nil, "Avisa si un enemigo te mira fijo")
crearSelector("Color ESP", "ESPColor", NOMBRES_COLORES, nil, "Color del ESP")
crearStepper("Rango ESP", "RangoESP", 100, 200, 5000, "%d", "Distancia máxima para mostrar ESP")

-- STUDS
setContenedor(tabStuds)
crearToggle("Contador de studs", "ContadorStuds", nil, "Distancia en studs sobre la cabeza")
crearToggle("Lineas a jugadores", "LineasStuds", nil, "Líneas desde abajo/centro al enemigo")
crearSelector("Origen lineas", "LineasOrigen", { "Abajo pantalla", "Centro" }, nil, "Desde dónde salen las líneas")
crearSelector("Color lineas", "ColorLineas", NOMBRES_LINEAS, nil, "Color de las líneas")
crearStepper("Grosor lineas", "GrosorLineas", 0.5, 0.5, 6, "%.1f", "Grosor en píxeles")

-- PUNTERIA
setContenedor(tabPunteria)
crearToggle("Marcador de tiro", "MarcadorTiro", nil, "Muestra un marcador en el objetivo")
crearToggle("Linea hacia el tiro", "LineaTiro", nil, "Línea desde el centro al objetivo")

-- PREDICCION
setContenedor(tabPrediccion)
crearToggle("Prediccion de movimiento", "Prediccion", nil, "Adelanta el punto de mira al movimiento")
crearStepper("Adelanto (ms)", "PrediccionMs", 10, 0, 300, "%d", "Milisegundos de adelanto")
crearToggle("Prediccion con gravedad", "PrediccionGravedad", nil, "Añade caída de bala al punto de mira")
crearStepper("Gravedad bala", "GravedadBala", 10, 50, 500, "%d", "Studs/s² de caída")

-- PROTECCION
setContenedor(tabProteccion)
crearToggle("Anti-void", "AntiVoid", nil, "Te rescata si caes al vacío")
crearStepper("Altura minima Y", "AntiVoidY", 10, -500, 0, "%d", "Y mínima antes de rescatar")
crearToggle("Anti-AFK", "AntiAFK", nil, "Evita que te kickeen por inactividad")
crearToggle("Auto-respawn", "AutoRespawn", nil, "Respawnea automáticamente")

-- SONIDO
setContenedor(tabSonido)
crearToggle("Sonido al matar", "SonidoKill", nil, "Reproduce un sonido al matar")
crearSelector("Sonido", "SonidoTipo", { "Ping", "Clic", "Snap", "Custom" }, nil, "Tipo de sonido")
crearStepper("Volumen", "Volumen", 0.1, 0.1, 3, "%.1f", "Volumen del sonido")
crearToggle("Sonidos UI", "SonidosUI", nil, "Sonidos al interactuar con el panel")

-- KILLS
setContenedor(tabKills)
crearToggle("Mostrar contador", "MostrarKills", nil, "Muestra el contador de kills")
crearToggle("Mostrar racha", "MostrarRacha", nil, "Muestra la racha actual")
crearToggle("Efecto al matar", "EfectoKill", nil, "Efecto visual +1")
crearToggle("Kill feed", "KillFeed", nil, "Muestra las últimas kills")

-- HUD
setContenedor(tabHUD)
crearToggle("Mostrar HUD info", "MostrarHUDInfo", nil, "Muestra FPS, ping, coords y velocidad")

-- AJUSTES
setContenedor(tabAjustes)
crearToggle("Notificaciones", "Notificaciones", nil, "Muestra notificaciones en pantalla")
crearToggle("Debug en consola", "Debug", nil, "Imprime información en la consola (F9)")

-- TEMAS
setContenedor(tabTemas)
crearSelector("Tema base", "TemaActual", NOMBRES_TEMAS, function(idx)
    cfg.UsarColorCustom = false
    aplicarTema(idx)
end, "Cambia la paleta del panel")
crearColorPicker("ColorCustom")

-- TECLAS
setContenedor(tabTeclas)
crearKeybind("Tecla Aimbot", "TeclaAimbot")
crearKeybind("Tecla ESP", "TeclaESP")
crearKeybind("Tecla Anti-aim", "TeclaAntiAim")
crearKeybind("Tecla Ocultar", "TeclaOcultar")
crearKeybind("Tecla Panico", "TeclaPanico")
crearKeybind("Tecla Auto-fire", "AutoFireTecla")

-- PERFILES
setContenedor(tabPerfiles)
crearBoton("Guardar en perfil 1", T.acento, function()
    perfiles[1] = serializar(); guardarPerfiles()
    notificar("Perfil 1 guardado", T.on)
end)
crearBoton("Guardar en perfil 2", T.acento, function()
    perfiles[2] = serializar(); guardarPerfiles()
    notificar("Perfil 2 guardado", T.on)
end)
crearBoton("Guardar en perfil 3", T.acento, function()
    perfiles[3] = serializar(); guardarPerfiles()
    notificar("Perfil 3 guardado", T.on)
end)
crearBoton("Cargar perfil 1", T.acento2, function()
    if perfiles[1] then deserializar(perfiles[1]); aplicarTema(cfg.TemaActual); guardarConfig()
        notificar("Perfil 1 cargado", T.acento2) end
end)
crearBoton("Cargar perfil 2", T.acento2, function()
    if perfiles[2] then deserializar(perfiles[2]); aplicarTema(cfg.TemaActual); guardarConfig()
        notificar("Perfil 2 cargado", T.acento2) end
end)
crearBoton("Cargar perfil 3", T.acento2, function()
    if perfiles[3] then deserializar(perfiles[3]); aplicarTema(cfg.TemaActual); guardarConfig()
        notificar("Perfil 3 cargado", T.acento2) end
end)

-- Activar primera tab
do
    local nombre = "Combate"
    local d = botonesTab[nombre]
    paginas[nombre].Visible = true
    tabActual = nombre
    d.boton.BackgroundColor3 = T.acento
    d.boton.BackgroundTransparency = 0.85
    d.ind.Size = UDim2.new(0, 3, 0, 20)
    d.lbl.TextColor3 = T.texto
    d.ico.TextColor3 = T.acento
end

buscador:GetPropertyChangedSignal("Text"):Connect(function()
    local q = string.lower(buscador.Text)
    for _, entry in ipairs(todasLasFilas) do
        if q == "" then
            entry.fila.Visible = true
        else
            entry.fila.Visible = string.find(entry.texto, q, 1, true) ~= nil
        end
    end
    if q ~= "" then
        for n, p in pairs(paginas) do p.Visible = false end
    else
        for n, p in pairs(paginas) do p.Visible = (n == tabActual) end
    end
end)

-- =========================================================
-- BARRA DE ESTADO
-- =========================================================
local barraEstado = Instance.new("Frame")
barraEstado.AnchorPoint = Vector2.new(0.5, 1)
barraEstado.Position = UDim2.new(0.5, 0, 1, -8)
barraEstado.Size = UDim2.new(1, -24, 0, 26)
barraEstado.BackgroundColor3 = T.tarjeta
barraEstado.BackgroundTransparency = 0.2
barraEstado.BorderSizePixel = 0
barraEstado.Parent = panel
Instance.new("UICorner", barraEstado).CornerRadius = UDim.new(0, 8)

local puntoEstado = Instance.new("Frame")
puntoEstado.AnchorPoint = Vector2.new(0, 0.5)
puntoEstado.Size = UDim2.fromOffset(8, 8)
puntoEstado.Position = UDim2.new(0, 10, 0.5, 0)
puntoEstado.BackgroundColor3 = T.off
puntoEstado.Parent = barraEstado
Instance.new("UICorner", puntoEstado).CornerRadius = UDim.new(1, 0)

local textoEstado = Instance.new("TextLabel")
textoEstado.Size = UDim2.new(1, -30, 1, 0)
textoEstado.Position = UDim2.fromOffset(24, 0)
textoEstado.BackgroundTransparency = 1
textoEstado.Text = "Listo"
textoEstado.TextXAlignment = Enum.TextXAlignment.Left
textoEstado.TextColor3 = T.sub
textoEstado.Font = Enum.Font.GothamMedium
textoEstado.TextSize = 11
textoEstado.Parent = barraEstado

local estadoActual = ""
local function setEstado(texto, color)
    if texto == estadoActual then return end
    estadoActual = texto
    textoEstado.Text = texto
    puntoEstado.BackgroundColor3 = color or T.off
end

-- =========================================================
-- HUD KILLS
-- =========================================================
local kills, racha = 0, 0
local ultimaKill = 0

local hudKills = Instance.new("TextLabel")
hudKills.AnchorPoint = Vector2.new(0, 0)
hudKills.Position = UDim2.fromOffset(15, 15)
hudKills.Size = UDim2.fromOffset(320, 30)
hudKills.BackgroundTransparency = 1
hudKills.TextXAlignment = Enum.TextXAlignment.Left
hudKills.TextColor3 = Color3.new(1, 1, 1)
hudKills.TextStrokeTransparency = 0
hudKills.TextStrokeColor3 = Color3.new(0, 0, 0)
hudKills.Font = Enum.Font.GothamBlack
hudKills.TextSize = 20
hudKills.Text = "Kills: 0"
hudKills.Parent = gui

local efectoKill = Instance.new("TextLabel")
efectoKill.AnchorPoint = Vector2.new(0.5, 0.5)
efectoKill.Position = UDim2.fromScale(0.5, 0.42)
efectoKill.Size = UDim2.fromOffset(220, 90)
efectoKill.BackgroundTransparency = 1
efectoKill.Text = "+1"
efectoKill.TextColor3 = T.verde
efectoKill.TextStrokeTransparency = 0
efectoKill.TextStrokeColor3 = Color3.new(0, 0, 0)
efectoKill.Font = Enum.Font.GothamBlack
efectoKill.TextSize = 64
efectoKill.TextTransparency = 1
efectoKill.Parent = gui

local function mostrarEfectoKill()
    efectoKill.Text = "+1"
    efectoKill.Position = UDim2.fromScale(0.5, 0.42)
    efectoKill.TextTransparency = 0
    efectoKill.TextSize = 64
    TweenService:Create(efectoKill, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.fromScale(0.5, 0.28),
        TextTransparency = 1,
        TextSize = 90,
    }):Play()
end

local function actualizarHUDKills()
    if not cfg.MostrarKills then
        hudKills.Visible = false
        return
    end
    hudKills.Visible = true
    if cfg.MostrarRacha and racha > 1 then
        hudKills.Text = "Kills: " .. kills .. "  |  Racha x" .. racha
    else
        hudKills.Text = "Kills: " .. kills
    end
end

local killFeedFrame = Instance.new("Frame")
killFeedFrame.AnchorPoint = Vector2.new(1, 0)
killFeedFrame.Position = UDim2.new(1, -20, 0, 420)
killFeedFrame.Size = UDim2.fromOffset(280, 200)
killFeedFrame.BackgroundTransparency = 1
killFeedFrame.Parent = gui

local kfLayout = Instance.new("UIListLayout", killFeedFrame)
kfLayout.Padding = UDim.new(0, 4)
kfLayout.SortOrder = Enum.SortOrder.LayoutOrder
kfLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right

local function agregarKillFeed(texto)
    if not cfg.KillFeed then return end
    local labels = {}
    for _, h in ipairs(killFeedFrame:GetChildren()) do
        if h:IsA("TextLabel") then table.insert(labels, h) end
    end
    if #labels >= 6 then labels[1]:Destroy() end

    local l = Instance.new("TextLabel")
    l.Size = UDim2.fromOffset(260, 24)
    l.BackgroundColor3 = T.fondoSuave
    l.BackgroundTransparency = 0.2
    l.Text = "  " .. texto
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextColor3 = T.texto
    l.Font = Enum.Font.GothamMedium
    l.TextSize = 11
    l.LayoutOrder = os.time()
    l.Parent = killFeedFrame
    Instance.new("UICorner", l).CornerRadius = UDim.new(0, 6)

    task.delay(5, function()
        TweenService:Create(l, TweenInfo.new(0.4), { BackgroundTransparency = 1, TextTransparency = 1 }):Play()
        task.wait(0.5)
        if l and l.Parent then l:Destroy() end
    end)
end

local hudInfo = Instance.new("TextLabel")
hudInfo.AnchorPoint = Vector2.new(0, 0)
hudInfo.Position = UDim2.fromOffset(15, 45)
hudInfo.Size = UDim2.fromOffset(320, 90)
hudInfo.BackgroundTransparency = 1
hudInfo.TextXAlignment = Enum.TextXAlignment.Left
hudInfo.TextYAlignment = Enum.TextYAlignment.Top
hudInfo.TextColor3 = Color3.new(1, 1, 1)
hudInfo.TextStrokeTransparency = 0
hudInfo.TextStrokeColor3 = Color3.new(0, 0, 0)
hudInfo.Font = Enum.Font.Code
hudInfo.TextSize = 13
hudInfo.Text = ""
hudInfo.Parent = gui

-- =========================================================
-- UTILIDADES
-- =========================================================
local function esAliado(otro)
    if not cfg.IgnorarEquipo then return false end
    if jugador.Neutral or jugador.Team == nil then return false end
    return otro.Team == jugador.Team
end

local function getHumanoid(instancia)
    local actual = instancia
    while actual and actual ~= workspace do
        if actual:IsA("Model") then
            local hum = actual:FindFirstChildOfClass("Humanoid")
            if hum then return hum, actual end
        end
        actual = actual.Parent
    end
    return nil
end

-- =========================================================
-- BUSQUEDA
-- =========================================================
local paramsLinea = RaycastParams.new()
paramsLinea.FilterType = Enum.RaycastFilterType.Exclude

local function hayLineaDeVision(parte)
    if not cfg.VerificarParedes then return true end
    local origen = camara.CFrame.Position
    local destino = parte.Position
    local filtro = { parte.Parent }
    if jugador.Character then table.insert(filtro, jugador.Character) end
    paramsLinea.FilterDescendantsInstances = filtro

    for _ = 1, 2 do
        local resultado = workspace:Raycast(origen, destino - origen, paramsLinea)
        if not resultado then return true end
        local obstaculo = resultado.Instance
        local atravesable = obstaculo.Transparency >= UMBRAL_TRANSPARENCIA
            or (IGNORAR_SIN_COLISION and not obstaculo.CanCollide)
        if atravesable then
            table.insert(filtro, obstaculo)
            paramsLinea.FilterDescendantsInstances = filtro
        else
            return false
        end
    end
    return false
end

local NOMBRES_PARTE = {
    Head = { "Head" },
    Torso = { "UpperTorso", "Torso", "HumanoidRootPart" },
    LeftArm = { "LeftUpperArm", "Left Arm" },
    RightArm = { "RightUpperArm", "Right Arm" },
    LeftLeg = { "LeftUpperLeg", "Left Leg" },
    RightLeg = { "RightUpperLeg", "Right Leg" },
}

local function buscarParte(char, clave)
    for _, nombre in NOMBRES_PARTE[clave] do
        local p = char:FindFirstChild(nombre)
        if p then return p end
    end
    return nil
end

local function elegirPartePorTrayectoria(char)
    local slot = math.clamp(cfg._TrayectoriaIdx, 1, 10)
    local clave = cfg.TrayectoriaSlots[slot] or "Head"
    return buscarParte(char, clave) or buscarParte(char, "Head") or buscarParte(char, "Torso")
end

local function avanzarTrayectoria()
    cfg._TrayectoriaIdx = cfg._TrayectoriaIdx + 1
    if cfg._TrayectoriaIdx > 10 then
        if cfg.TrayectoriaLoop then
            cfg._TrayectoriaIdx = 1
        else
            cfg._TrayectoriaIdx = 10
        end
    end
    if refrescadorSlots then refrescadorSlots() end
end

local function elegirParte(char)
    if not char then return nil end
    if cfg.UsarTrayectoria then
        return elegirPartePorTrayectoria(char)
    end

    local cabeza = buscarParte(char, "Head")
    local torso = buscarParte(char, "Torso")

    if cfg.PriorizarCabeza then
        if cabeza then return cabeza end
        return torso
    end

    if not cabeza then return torso end
    if not torso then return cabeza end
    if hayLineaDeVision(cabeza) then return cabeza end
    return torso
end

-- =========================================================
-- AIMBOT
-- =========================================================
local objetivoFijo = nil
local paramsMira = RaycastParams.new()
paramsMira.FilterType = Enum.RaycastFilterType.Exclude

local function parteDe(otro)
    local c = otro.Character
    if not c then return nil end
    return elegirParte(c)
end

local function objetivoValido(parte, radio)
    if not parte or not parte.Parent then return false end
    local modelo = parte.Parent
    local hum = modelo:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    local otro = Players:GetPlayerFromCharacter(modelo)
    if not otro or esAliado(otro) then return false end

    local pos, enPantalla = camara:WorldToViewportPoint(parte.Position)
    if not enPantalla then return false end
    local centro = camara.ViewportSize / 2
    if (Vector2.new(pos.X, pos.Y) - centro).Magnitude > radio then return false end
    if (parte.Position - camara.CFrame.Position).Magnitude > cfg.Rango3D then return false end
    return hayLineaDeVision(parte)
end

local function objetivoAmenaza(otro)
    local char = otro.Character
    local head = char and char:FindFirstChild("Head")
    local miChar = jugador.Character
    local miHead = miChar and miChar:FindFirstChild("Head")
    if not head or not miHead then return false end
    local dir = (miHead.Position - head.Position)
    local dist = dir.Magnitude
    if dist < 1 or dist > 500 then return false end
    return head.CFrame.LookVector:Dot(dir.Unit) > 0.95
end

local function elegirObjetivoAimbot()
    if cfg.TrabarObjetivo and objetivoFijo and objetivoFijo.Parent then
        local humActual = objetivoFijo.Parent:FindFirstChildOfClass("Humanoid")
        if humActual and humActual.Health > 0 then
            local actualizada = elegirParte(objetivoFijo.Parent) or objetivoFijo
            if objetivoValido(actualizada, cfg.FovRadio * 1.5) then
                objetivoFijo = actualizada
                return actualizada
            end
        else
            objetivoFijo = nil
        end
    end

    local char = jugador.Character
    if char then
        paramsMira.FilterDescendantsInstances = { char }
        local r = workspace:Raycast(camara.CFrame.Position, camara.CFrame.LookVector * cfg.Rango3D, paramsMira)
        if r then
            local _, modelo = getHumanoid(r.Instance)
            local otro = modelo and Players:GetPlayerFromCharacter(modelo)
            if otro and not esAliado(otro) then
                local parte = parteDe(otro)
                if parte and objetivoValido(parte, cfg.FovRadio) then
                    objetivoFijo = parte
                    return parte
                end
            end
        end
    end

    local centro = camara.ViewportSize / 2
    local mejor, mejorPuntaje = nil, math.huge

    for _, otro in Players:GetPlayers() do
        if otro ~= jugador and not esAliado(otro) then
            local parte = parteDe(otro)
            if parte and objetivoValido(parte, cfg.FovRadio) then
                local pos = camara:WorldToViewportPoint(parte.Position)
                local distPantalla = (Vector2.new(pos.X, pos.Y) - centro).Magnitude
                local dist3D = (parte.Position - camara.CFrame.Position).Magnitude
                local hum = parte.Parent:FindFirstChildOfClass("Humanoid")

                local puntaje
                if cfg.PriorizarAmenaza and objetivoAmenaza(otro) then
                    puntaje = -10000 + dist3D
                elseif cfg.PriorizarPocaVida and hum then
                    puntaje = hum.Health
                elseif cfg.PriorizarCercano then
                    puntaje = dist3D
                else
                    puntaje = distPantalla
                end

                if puntaje < mejorPuntaje then
                    mejor, mejorPuntaje = parte, puntaje
                end
            end
        end
    end
    objetivoFijo = mejor
    return mejor
end

-- =========================================================
-- DETECCION DE AIMBOTS ENEMIGOS
-- =========================================================
local sospechosos = {}

local function actualizarDeteccionAimbots(dt)
    if not cfg.DetectarAimbots then
        for p in pairs(sospechosos) do sospechosos[p] = nil end
        return
    end
    local miChar = jugador.Character
    local miHead = miChar and miChar:FindFirstChild("Head")
    if not miHead then return end
    local miPos = miHead.Position

    for _, otro in Players:GetPlayers() do
        if otro ~= jugador and not esAliado(otro) then
            local char = otro.Character
            local head = char and char:FindFirstChild("Head")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if head and hum and hum.Health > 0 then
                local direccion = head.CFrame.LookVector
                local haciaMi = (miPos - head.Position)
                local dist = haciaMi.Magnitude
                if dist > 1 and dist < 300 then
                    local dot = direccion:Dot(haciaMi.Unit)
                    if dot > 0.995 then
                        if not sospechosos[otro] then
                            sospechosos[otro] = { tiempo = 0, alertado = false }
                        end
                        sospechosos[otro].tiempo += dt
                        if sospechosos[otro].tiempo > 1.5 and not sospechosos[otro].alertado then
                            sospechosos[otro].alertado = true
                            notificar("[!] " .. otro.DisplayName .. " te mira fijo", T.rojo)
                        end
                    else
                        if sospechosos[otro] and sospechosos[otro].alertado then
                            sospechosos[otro].tiempo -= dt * 2
                            if sospechosos[otro].tiempo < 0 then sospechosos[otro] = nil end
                        else
                            sospechosos[otro] = nil
                        end
                    end
                end
            end
        end
    end
end

-- =========================================================
-- ANTI-VOID
-- =========================================================
local ultimaPosicionSegura = nil
local ultimoAntiVoid = 0

local function actualizarAntiVoid()
    if not cfg.AntiVoid then return end
    local char = jugador.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if hrp.Position.Y > cfg.AntiVoidY + 20 then
        ultimaPosicionSegura = hrp.Position
    end
    if hrp.Position.Y < cfg.AntiVoidY then
        local ahora = os.clock()
        if ahora - ultimoAntiVoid > 1 then
            ultimoAntiVoid = ahora
            local destino = ultimaPosicionSegura or Vector3.new(0, 50, 0)
            hrp.CFrame = CFrame.new(destino + Vector3.new(0, 5, 0))
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            notificar("Anti-void activado", T.amarillo)
        end
    end
end

-- =========================================================
-- ANTI-AFK
-- =========================================================
task.spawn(function()
    while true do
        task.wait(25)
        if cfg.AntiAFK then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    end
end)

-- =========================================================
-- AUTO-RESPAWN
-- =========================================================
local ultimoRespawn = 0

local function vigilarAutoRespawn()
    local char = jugador.Character
    local necesita = false
    if not char then
        necesita = true
    else
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health <= 0 then necesita = true end
    end
    if necesita and cfg.AutoRespawn then
        local ahora = os.clock()
        if ahora - ultimoRespawn > 2 then
            ultimoRespawn = ahora
            pcall(function() jugador:LoadCharacter() end)
        end
    end
end

-- =========================================================
-- ESP + STUDS + LINEAS + SKELETON + BOX + OFFSCREEN
-- =========================================================
local marcas = {}
local lineasJugador = {}
local studsTexto = {}
local huesosLineas = {}

local HUESOS = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
}

local offScreenArrows = {}

local function quitarMarca(otro)
    local m = marcas[otro]
    if m then
        if m.highlight then m.highlight:Destroy() end
        if m.billboard then m.billboard:Destroy() end
        if m.hitbox then m.hitbox:Destroy() end
        if m.box then m.box:Destroy() end
        marcas[otro] = nil
    end
    if lineasJugador[otro] then lineasJugador[otro]:Destroy(); lineasJugador[otro] = nil end
    if studsTexto[otro] then studsTexto[otro]:Destroy(); studsTexto[otro] = nil end
    if huesosLineas[otro] then
        for _, l in ipairs(huesosLineas[otro]) do l:Destroy() end
        huesosLineas[otro] = nil
    end
    if offScreenArrows[otro] then offScreenArrows[otro]:Destroy(); offScreenArrows[otro] = nil end
end

local function crearMarca(otro)
    quitarMarca(otro)
    local personaje = otro.Character
    if not personaje then return end
    local cabeza = personaje:FindFirstChild("Head") or personaje:FindFirstChild("HumanoidRootPart")
    if not cabeza then return end
    local colorESP = COLORES_ESP[cfg.ESPColor].color

    local highlight = Instance.new("Highlight")
    highlight.Adornee = personaje
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = colorESP
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.6
    highlight.OutlineTransparency = 0
    highlight.Parent = contenedorESP

    local hitbox = Instance.new("SelectionBox")
    hitbox.Adornee = personaje
    hitbox.LineThickness = 0.05
    hitbox.Color3 = colorESP
    hitbox.Transparency = 0.4
    hitbox.SurfaceTransparency = 1
    hitbox.Visible = false
    hitbox.Parent = contenedorESP

    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = cabeza
    billboard.Size = UDim2.fromOffset(160, 60)
    billboard.StudsOffset = Vector3.new(0, 2.8, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = contenedorESP

    local etiqueta = Instance.new("TextLabel")
    etiqueta.Size = UDim2.new(1, 0, 0, 46)
    etiqueta.BackgroundTransparency = 1
    etiqueta.Text = ""
    etiqueta.TextColor3 = Color3.new(1, 1, 1)
    etiqueta.TextStrokeTransparency = 0
    etiqueta.TextStrokeColor3 = Color3.new(0, 0, 0)
    etiqueta.Font = Enum.Font.GothamBold
    etiqueta.TextSize = 13
    etiqueta.Parent = billboard

    local fondoBarra = Instance.new("Frame")
    fondoBarra.AnchorPoint = Vector2.new(0.5, 0)
    fondoBarra.Position = UDim2.new(0.5, 0, 0, 50)
    fondoBarra.Size = UDim2.fromOffset(90, 6)
    fondoBarra.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    fondoBarra.BorderSizePixel = 0
    fondoBarra.Parent = billboard
    Instance.new("UICorner", fondoBarra).CornerRadius = UDim.new(1, 0)

    local relleno = Instance.new("Frame")
    relleno.Size = UDim2.fromScale(1, 1)
    relleno.BackgroundColor3 = T.on
    relleno.BorderSizePixel = 0
    relleno.Parent = fondoBarra
    Instance.new("UICorner", relleno).CornerRadius = UDim.new(1, 0)

    local box = Instance.new("Frame")
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 0
    box.Visible = false
    box.Parent = gui
    local boxStroke = Instance.new("UIStroke", box)
    boxStroke.Color = colorESP
    boxStroke.Thickness = 1.5
    boxStroke.Transparency = 0.2

    local studs = Instance.new("TextLabel")
    studs.AnchorPoint = Vector2.new(0.5, 0.5)
    studs.Size = UDim2.fromOffset(80, 20)
    studs.BackgroundTransparency = 1
    studs.Text = ""
    studs.TextColor3 = Color3.fromRGB(255, 255, 255)
    studs.TextStrokeTransparency = 0
    studs.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    studs.Font = Enum.Font.GothamBold
    studs.TextSize = 13
    studs.ZIndex = 5
    studs.Visible = false
    studs.Parent = carpetaStuds

    local linea = Instance.new("Frame")
    linea.AnchorPoint = Vector2.new(0.5, 0.5)
    linea.BackgroundColor3 = COLORES_LINEA[cfg.ColorLineas].color
    linea.BorderSizePixel = 0
    linea.ZIndex = 1
    linea.Visible = false
    linea.Parent = carpetaLineas

    local huesos = {}
    for i = 1, #HUESOS do
        local l = Instance.new("Frame")
        l.AnchorPoint = Vector2.new(0.5, 0.5)
        l.BackgroundColor3 = colorESP
        l.BorderSizePixel = 0
        l.ZIndex = 3
        l.Visible = false
        l.Parent = gui
        huesos[i] = l
    end

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.fromOffset(24, 24)
    arrow.BackgroundTransparency = 1
    arrow.Text = "➤"
    arrow.TextColor3 = colorESP
    arrow.TextStrokeTransparency = 0
    arrow.TextStrokeColor3 = Color3.new(0, 0, 0)
    arrow.Font = Enum.Font.GothamBlack
    arrow.TextSize = 24
    arrow.Visible = false
    arrow.Parent = gui

    marcas[otro] = {
        highlight = highlight, billboard = billboard, etiqueta = etiqueta,
        fondoBarra = fondoBarra, relleno = relleno, cabeza = cabeza,
        hitbox = hitbox, box = box, boxStroke = boxStroke,
    }
    studsTexto[otro] = studs
    lineasJugador[otro] = linea
    huesosLineas[otro] = huesos
    offScreenArrows[otro] = arrow
end

local function vigilar(otro)
    if otro == jugador then return end
    otro.CharacterAdded:Connect(function()
        task.wait(0.2)
        crearMarca(otro)
    end)
    otro.CharacterRemoving:Connect(function() quitarMarca(otro) end)
    if otro.Character then crearMarca(otro) end
end

for _, otro in Players:GetPlayers() do vigilar(otro) end
Players.PlayerAdded:Connect(vigilar)
Players.PlayerRemoving:Connect(quitarMarca)

local function actualizarESP()
    for otro, m in marcas do
        local personaje = otro.Character
        local humanoide = personaje and personaje:FindFirstChildOfClass("Humanoid")
        local distancia = (m.cabeza and m.cabeza.Parent)
            and (m.cabeza.Position - camara.CFrame.Position).Magnitude or math.huge
        local visible = cfg.ESP and humanoide ~= nil and humanoide.Health > 0
            and not esAliado(otro) and distancia <= cfg.RangoESP
        m.billboard.Enabled = visible
        m.highlight.Enabled = visible and cfg.Chams
        if m.hitbox then m.hitbox.Visible = visible and cfg.HitboxJugador end
        if visible then
            local hp = humanoide.Health
            local frac = math.clamp(hp / math.max(humanoide.MaxHealth, 1), 0, 1)
            local prefijo = ""
            if cfg.DetectarAimbots and sospechosos[otro] and sospechosos[otro].alertado then
                prefijo = "[!] "
            end
            local texto = prefijo .. otro.DisplayName .. "\n" .. math.floor(hp) .. " HP"
            if cfg.ESPArma then
                local arma = personaje:FindFirstChildOfClass("Tool")
                texto = texto .. "\n[" .. (arma and arma.Name or "Sin arma") .. "]"
            end
            m.etiqueta.Text = texto
            m.etiqueta.TextColor3 = (cfg.DetectarAimbots and sospechosos[otro] and sospechosos[otro].alertado) and T.rojo or Color3.new(1, 1, 1)
            m.fondoBarra.Visible = cfg.ESPVida
            m.relleno.Size = UDim2.fromScale(frac, 1)
            m.relleno.BackgroundColor3 = Color3.fromHSV(0.33 * frac, 0.8, 1)
            if cfg.ESPBox then
                local pos, onScreen = camara:WorldToViewportPoint(m.cabeza.Position)
                if onScreen then
                    local headTop = camara:WorldToViewportPoint(m.cabeza.Position + Vector3.new(0, 1.5, 0))
                    local hrp = personaje:FindFirstChild("HumanoidRootPart")
                    local feetPos = hrp and camara:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                    if feetPos then
                        local h = math.abs(feetPos.Y - headTop.Y)
                        local w = h * 0.55
                        m.box.Size = UDim2.fromOffset(w, h)
                        m.box.Position = UDim2.fromOffset(pos.X - w/2, headTop.Y)
                        m.box.Visible = true
                    else
                        m.box.Visible = false
                    end
                else
                    m.box.Visible = false
                end
            else
                m.box.Visible = false
            end
            m.boxStroke.Color = COLORES_ESP[cfg.ESPColor].color
        else
            if m.box then m.box.Visible = false end
        end
    end
end

local function actualizarStuds()
    for otro, m in marcas do
        local studs = studsTexto[otro]
        if studs then
            local personaje = otro.Character
            local humanoide = personaje and personaje:FindFirstChildOfClass("Humanoid")
            local visible = cfg.ContadorStuds and cfg.ESP and humanoide ~= nil
                and humanoide.Health > 0 and not esAliado(otro)
            if visible and m.cabeza and m.cabeza.Parent then
                local pos, enPantalla = camara:WorldToViewportPoint(m.cabeza.Position + Vector3.new(0, 3.5, 0))
                if enPantalla and pos.Z > 0 then
                    local dist = math.floor((m.cabeza.Position - camara.CFrame.Position).Magnitude)
                    studs.Text = dist .. " studs"
                    studs.Position = UDim2.fromOffset(pos.X, pos.Y)
                    studs.Visible = true
                else
                    studs.Visible = false
                end
            else
                studs.Visible = false
            end
        end
    end
end

local function actualizarLineasJugador()
    for otro, m in marcas do
        local l = lineasJugador[otro]
        if l then
            local personaje = otro.Character
            local humanoide = personaje and personaje:FindFirstChildOfClass("Humanoid")
            local visible = cfg.LineasStuds and cfg.ESP and humanoide ~= nil
                and humanoide.Health > 0 and not esAliado(otro)
            if visible and m.cabeza and m.cabeza.Parent then
                local posCabeza, enPantalla = camara:WorldToViewportPoint(m.cabeza.Position)
                if enPantalla and posCabeza.Z > 0 then
                    local desde
                    if cfg.LineasOrigen == 1 then
                        desde = Vector2.new(camara.ViewportSize.X / 2, camara.ViewportSize.Y)
                    else
                        desde = Vector2.new(camara.ViewportSize.X / 2, camara.ViewportSize.Y / 2)
                    end
                    local hasta = Vector2.new(posCabeza.X, posCabeza.Y)
                    local d = hasta - desde
                    local largo = d.Magnitude
                    l.Size = UDim2.fromOffset(largo, cfg.GrosorLineas)
                    l.Position = UDim2.fromOffset((desde.X + hasta.X) / 2, (desde.Y + hasta.Y) / 2)
                    l.Rotation = math.deg(math.atan2(d.Y, d.X))
                    l.BackgroundColor3 = COLORES_LINEA[cfg.ColorLineas].color
                    l.Visible = largo > 4
                else
                    l.Visible = false
                end
            else
                l.Visible = false
            end
        end
    end
end

local function actualizarSkeleton()
    for otro, huesos in pairs(huesosLineas) do
        local personaje = otro.Character
        local humanoide = personaje and personaje:FindFirstChildOfClass("Humanoid")
        local visible = cfg.ESPSkeleton and cfg.ESP and humanoide ~= nil
            and humanoide.Health > 0 and not esAliado(otro)
        if visible then
            for i, def in ipairs(HUESOS) do
                local a = personaje:FindFirstChild(def[1])
                local b = personaje:FindFirstChild(def[2])
                if a and b then
                    local pa, ona = camara:WorldToViewportPoint(a.Position)
                    local pb, onb = camara:WorldToViewportPoint(b.Position)
                    local l = huesos[i]
                    if ona and onb and pa.Z > 0 and pb.Z > 0 then
                        local d = Vector2.new(pb.X - pa.X, pb.Y - pa.Y)
                        local largo = d.Magnitude
                        l.Size = UDim2.fromOffset(largo, 1.5)
                        l.Position = UDim2.fromOffset((pa.X + pb.X) / 2, (pa.Y + pb.Y) / 2)
                        l.Rotation = math.deg(math.atan2(d.Y, d.X))
                        l.BackgroundColor3 = COLORES_ESP[cfg.ESPColor].color
                        l.Visible = true
                    else
                        l.Visible = false
                    end
                elseif huesos[i] then
                    huesos[i].Visible = false
                end
            end
        else
            for _, l in ipairs(huesos) do l.Visible = false end
        end
    end
end

local function actualizarOffScreen()
    local centro = camara.ViewportSize / 2
    for otro, arrow in pairs(offScreenArrows) do
        local m = marcas[otro]
        local visible = cfg.OffScreenInd and cfg.ESP and m and m.cabeza and m.cabeza.Parent
        local personaje = otro.Character
        local hum = personaje and personaje:FindFirstChildOfClass("Humanoid")
        if visible and hum and hum.Health > 0 and not esAliado(otro) then
            local pos, enPantalla = camara:WorldToViewportPoint(m.cabeza.Position)
            if not enPantalla or pos.X < 0 or pos.Y < 0
            or pos.X > camara.ViewportSize.X or pos.Y > camara.ViewportSize.Y then
                local dir = Vector2.new(pos.X - centro.X, pos.Y - centro.Y)
                if dir.Magnitude < 0.01 then dir = Vector2.new(1, 0) end
                dir = dir.Unit
                local radio = math.min(centro.X, centro.Y) * 0.75
                local posBorde = centro + dir * radio
                arrow.Position = UDim2.fromOffset(posBorde.X - 12, posBorde.Y - 12)
                arrow.Rotation = math.deg(math.atan2(dir.Y, dir.X))
                arrow.Visible = true
                arrow.TextColor3 = COLORES_ESP[cfg.ESPColor].color
            else
                arrow.Visible = false
            end
        else
            arrow.Visible = false
        end
    end
end

-- =========================================================
-- PREDICCION / MARCADOR
-- =========================================================
local function puntoApuntar(parte)
    local pos = parte.Position
    local modelo = parte.Parent
    local raiz = modelo and modelo:FindFirstChild("HumanoidRootPart")
    if raiz and (cfg.Prediccion or cfg.PrediccionGravedad) then
        local v = raiz.AssemblyLinearVelocity
        local ms = math.clamp(cfg.PrediccionMs, 0, 500) / 1000
        if cfg.Prediccion then
            pos += Vector3.new(v.X, 0, v.Z) * ms
        end
        if cfg.PrediccionGravedad then
            local dist = (parte.Position - camara.CFrame.Position).Magnitude
            local tiempo = dist / 500
            local caida = 0.5 * cfg.GravedadBala * tiempo * tiempo
            pos += Vector3.new(0, caida * 0.3, 0)
        end
    end
    return pos
end

local NOMBRE_INSTANCIA = {
    Head = "Cabeza", UpperTorso = "Torso", Torso = "Torso", HumanoidRootPart = "Torso",
    LeftUpperArm = "Brazo izq.", ["Left Arm"] = "Brazo izq.",
    RightUpperArm = "Brazo der.", ["Right Arm"] = "Brazo der.",
    LeftUpperLeg = "Pierna izq.", ["Left Leg"] = "Pierna izq.",
    RightUpperLeg = "Pierna der.", ["Right Leg"] = "Pierna der.",
}

local linea = Instance.new("Frame")
linea.AnchorPoint = Vector2.new(0.5, 0.5)
linea.BackgroundColor3 = T.rojo
linea.BackgroundTransparency = 0.45
linea.BorderSizePixel = 0
linea.Visible = false
linea.Parent = gui

local marcador = Instance.new("Frame")
marcador.AnchorPoint = Vector2.new(0.5, 0.5)
marcador.Size = UDim2.fromOffset(26, 26)
marcador.BackgroundTransparency = 1
marcador.Visible = false
marcador.ZIndex = 5
marcador.Parent = gui
Instance.new("UICorner", marcador).CornerRadius = UDim.new(1, 0)
local trazoMarcador = Instance.new("UIStroke", marcador)
trazoMarcador.Color = T.rojo
trazoMarcador.Thickness = 2

for _, medida in { Vector2.new(2, 14), Vector2.new(14, 2) } do
    local barra = Instance.new("Frame")
    barra.AnchorPoint = Vector2.new(0.5, 0.5)
    barra.Position = UDim2.fromScale(0.5, 0.5)
    barra.Size = UDim2.fromOffset(medida.X, medida.Y)
    barra.BackgroundColor3 = T.rojo
    barra.BorderSizePixel = 0
    barra.ZIndex = 5
    barra.Parent = marcador
end

local textoMarcador = Instance.new("TextLabel")
textoMarcador.AnchorPoint = Vector2.new(0.5, 0)
textoMarcador.Position = UDim2.new(0.5, 0, 1, 3)
textoMarcador.Size = UDim2.fromOffset(140, 14)
textoMarcador.BackgroundTransparency = 1
textoMarcador.TextColor3 = Color3.new(1, 1, 1)
textoMarcador.TextStrokeTransparency = 0
textoMarcador.TextStrokeColor3 = Color3.new(0, 0, 0)
textoMarcador.Font = Enum.Font.GothamBold
textoMarcador.TextSize = 11
textoMarcador.ZIndex = 5
textoMarcador.Parent = marcador

local function actualizarMarcador(objetivo)
    if not cfg.MarcadorTiro or not objetivo or not objetivo.Parent then
        marcador.Visible = false
        linea.Visible = false
        return
    end
    local p = puntoApuntar(objetivo)
    local pos, enPantalla = camara:WorldToViewportPoint(p)
    if not enPantalla then
        marcador.Visible = false
        linea.Visible = false
        return
    end
    marcador.Position = UDim2.fromOffset(pos.X, pos.Y)
    marcador.Visible = true
    local dist = math.floor((p - camara.CFrame.Position).Magnitude)
    textoMarcador.Text = (NOMBRE_INSTANCIA[objetivo.Name] or objetivo.Name) .. "  -  " .. dist .. " studs"
    if cfg.LineaTiro then
        local desde = camara.ViewportSize / 2
        local hasta = Vector2.new(pos.X, pos.Y)
        local d = hasta - desde
        local largo = d.Magnitude
        linea.Size = UDim2.fromOffset(largo, 2)
        linea.Position = UDim2.fromOffset((desde.X + hasta.X) / 2, (desde.Y + hasta.Y) / 2)
        linea.Rotation = math.deg(math.atan2(d.Y, d.X))
        linea.Visible = largo > 4
    else
        linea.Visible = false
    end
end

-- =========================================================
-- SONIDO
-- =========================================================
local SONIDOS = {
    "rbxasset://sounds/electronicpingshort.wav",
    "rbxasset://sounds/clickfast.wav",
    "rbxasset://sounds/snap.mp3",
}

local function reproducirKill()
    local id = SONIDOS[cfg.SonidoTipo]
    if cfg.SonidoTipo == 4 and cfg.SonidoCustom ~= "" then id = cfg.SonidoCustom end
    id = id or SONIDOS[1]
    local s = Instance.new("Sound")
    s.SoundId = id
    s.Volume = cfg.Volumen
    s.Parent = SoundService
    s:Play()
    Debris:AddItem(s, 4)
end

-- =========================================================
-- DETECCION DE KILLS + AVANCE DE TRAYECTORIA
-- =========================================================
local kill = { modelo = nil, tMira = 0, tDisparo = 0 }
local paramsKill = RaycastParams.new()
paramsKill.FilterType = Enum.RaycastFilterType.Exclude

local function actualizarMira()
    local char = jugador.Character
    if not char then return end
    paramsKill.FilterDescendantsInstances = { char }
    local r = workspace:Raycast(camara.CFrame.Position, camara.CFrame.LookVector * cfg.DistanciaDisparo, paramsKill)
    if r then
        local h, modelo = getHumanoid(r.Instance)
        if h and modelo then
            kill.modelo = modelo
            kill.tMira = os.clock()
        end
    end
end

local function alMorir(otro, hum)
    local fueMio
    local tag = hum:FindFirstChild("creator")
    if tag and tag:IsA("ObjectValue") then
        fueMio = (tag.Value == jugador)
    else
        local ahora = os.clock()
        fueMio = kill.modelo == otro.Character
            and ahora - kill.tMira < 1
            and ahora - kill.tDisparo < 1.5
    end
    if fueMio then
        if cfg.SonidoKill then reproducirKill() end
        kills += 1
        local ahora2 = os.clock()
        if ahora2 - ultimaKill < 5 then racha += 1 else racha = 1 end
        ultimaKill = ahora2
        actualizarHUDKills()
        if cfg.EfectoKill then mostrarEfectoKill() end
        agregarKillFeed("Mataste a " .. otro.DisplayName)
        if cfg.UsarTrayectoria then
            avanzarTrayectoria()
        end
    end
end

UserInputService.InputBegan:Connect(function(input, procesado)
    if procesado then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        kill.tDisparo = os.clock()
        if cfg.UsarTrayectoria and cfg.Aimbot then
            avanzarTrayectoria()
        end
    end
end)

local function vigilarMuerte(otro)
    if otro == jugador then return end
    local function conectar(char)
        local hum = char:WaitForChild("Humanoid", 5)
        if hum then hum.Died:Connect(function() alMorir(otro, hum) end) end
    end
    otro.CharacterAdded:Connect(conectar)
    if otro.Character then task.spawn(conectar, otro.Character) end
end

for _, otro in Players:GetPlayers() do vigilarMuerte(otro) end
Players.PlayerAdded:Connect(vigilarMuerte)

-- =========================================================
-- TRIGGERBOT
-- =========================================================
local ultimoTrigger = 0
local rafagaRestante = 0
local ultimoRafaga = 0

local function actualizarTriggerbot()
    if not cfg.Triggerbot then return end
    local char = jugador.Character
    if not char then return end
    local miHum = char:FindFirstChildOfClass("Humanoid")
    if not miHum or miHum.Health <= 0 then return end

    local ahora = os.clock() * 1000

    if rafagaRestante > 0 then
        if ahora - ultimoRafaga >= cfg.TriggerRafagaMs then
            ultimoRafaga = ahora
            rafagaRestante -= 1
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new())
            end)
        end
        return
    end

    if ahora - ultimoTrigger < cfg.TriggerDelay then return end

    paramsKill.FilterDescendantsInstances = { char }
    local r = workspace:Raycast(
        camara.CFrame.Position,
        camara.CFrame.LookVector * cfg.TriggerRango,
        paramsKill
    )
    if r then
        local h, modelo = getHumanoid(r.Instance)
        if h and modelo and h.Health > 0 then
            local otro = Players:GetPlayerFromCharacter(modelo)
            if otro and not esAliado(otro) then
                ultimoTrigger = ahora
                rafagaRestante = math.max(1, cfg.TriggerRafaga) - 1
                ultimoRafaga = ahora
                pcall(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton1(Vector2.new())
                end)
            end
        end
    end
end

-- =========================================================
-- AUTO-FIRE
-- =========================================================
local ultimoAutoFire = 0

UserInputService.InputBegan:Connect(function(input, procesado)
    if procesado then return end
    if input.KeyCode == cfg.AutoFireTecla then
        cfg._AutoFireActivo = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == cfg.AutoFireTecla then
        cfg._AutoFireActivo = false
    end
end)

local function actualizarAutoFire()
    if not cfg.AutoFireHold or not cfg._AutoFireActivo then return end
    local char = jugador.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end
    local ahora = os.clock() * 1000
    if ahora - ultimoAutoFire < cfg.AutoFireMs then return end
    ultimoAutoFire = ahora
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new())
    end)
end

-- =========================================================
-- ANTI-AIM
-- =========================================================
local anguloAntiAim = 0

local function actualizarAntiAim(dt)
    local char = jugador.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if not cfg.AntiAim then
        if hum.AutoRotate == false then hum.AutoRotate = true end
        return
    end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    hum.AutoRotate = false
    local modo = cfg.AntiAimModo
    local base = camara.CFrame.LookVector
    if modo == 1 then
        anguloAntiAim = (anguloAntiAim + cfg.AntiAimVel * dt) % 360
        local rad = math.rad(anguloAntiAim)
        local dir = Vector3.new(math.cos(rad), 0, math.sin(rad))
        root.CFrame = CFrame.lookAt(root.Position, root.Position + dir)
    elseif modo == 2 then
        anguloAntiAim = anguloAntiAim + dt * 10
        local offset = (math.floor(anguloAntiAim) % 2 == 0) and 180 or 0
        local rad = math.rad(offset)
        local plano = Vector3.new(base.X, 0, base.Z).Unit
        local dir = Vector3.new(
            plano.X * math.cos(rad) - plano.Z * math.sin(rad),
            0,
            plano.X * math.sin(rad) + plano.Z * math.cos(rad)
        )
        root.CFrame = CFrame.lookAt(root.Position, root.Position + dir)
    elseif modo == 3 then
        local plano = Vector3.new(base.X, 0, base.Z).Unit
        root.CFrame = CFrame.lookAt(root.Position, root.Position - plano)
    end
end

local function desactivarAntiAim()
    local char = jugador.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.AutoRotate = true end
end

jugador.CharacterAdded:Connect(function(char)
    task.wait(0.3)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.AutoRotate = true end
end)

-- =========================================================
-- TECLAS
-- =========================================================
local function alternar(clave)
    cfg[clave] = not cfg[clave]
    if refrescadores[clave] then refrescadores[clave]() end
    if clave == "AntiAim" and not cfg.AntiAim then
        desactivarAntiAim()
    end
    guardarConfig()
end

local function panico()
    cfg.Aimbot = false
    cfg.ESP = false
    cfg.Triggerbot = false
    cfg.AntiAim = false
    cfg.LineaTiro = false
    cfg.MarcadorTiro = false
    cfg.ContadorStuds = false
    cfg.LineasStuds = false
    cfg.AutoFireHold = false
    for _, k in ipairs({ "Aimbot", "ESP", "Triggerbot", "AntiAim",
                         "LineaTiro", "MarcadorTiro", "ContadorStuds", "LineasStuds", "AutoFireHold" }) do
        if refrescadores[k] then refrescadores[k]() end
    end
    panel.Visible = false
    notificar("PANICO: todo apagado", T.rojo)
    guardarConfig()
end

UserInputService.InputBegan:Connect(function(input, procesado)
    if procesado then return end
    if input.KeyCode == cfg.TeclaAimbot then
        alternar("Aimbot")
        notificar(cfg.Aimbot and "Aimbot ON" or "Aimbot OFF", cfg.Aimbot and T.on or T.off)
    elseif input.KeyCode == cfg.TeclaESP then
        alternar("ESP")
        notificar(cfg.ESP and "ESP ON" or "ESP OFF", cfg.ESP and T.on or T.off)
    elseif input.KeyCode == cfg.TeclaAntiAim then
        alternar("AntiAim")
        notificar(cfg.AntiAim and "Anti-aim ON" or "Anti-aim OFF", cfg.AntiAim and T.on or T.off)
    elseif input.KeyCode == cfg.TeclaPanico then
        panico()
    elseif input.KeyCode == cfg.TeclaOcultar then
        panel.Visible = not panel.Visible
    end
end)

-- =========================================================
-- CURVA
-- =========================================================
local function aplicarCurva(t, tipo)
    t = math.clamp(t, 0, 1)
    if tipo == 1 then return t
    elseif tipo == 2 then return t * t
    elseif tipo == 3 then return math.sin(t * math.pi / 2)
    elseif tipo == 4 then
        if t <= 0 then return 0 end
        if t >= 1 then return 1 end
        return math.pow(2, 10 * (t - 1))
    end
    return t
end

-- =========================================================
-- LOOP PRINCIPAL
-- =========================================================
local tAcumDeteccion = 0
local tAcumHUD = 0
local tAcumFrame = 0
local frames = 0
local fpsActual = 0
local refrescadorSlotsGuardado = false

RunService:BindToRenderStep("PanelCombinado", Enum.RenderPriority.Camera.Value + 1, function(dt)
    camara = workspace.CurrentCamera

    if not refrescadorSlotsGuardado and refrescadorSlots then
        task.spawn(function()
            while true do
                task.wait(0.25)
                pcall(refrescadorSlots)
            end
        end)
        refrescadorSlotsGuardado = true
    end

    local fovEfectivo = cfg.FovRadio
    if cfg.FovDinamico and objetivoFijo then
        fovEfectivo = math.max(cfg.FovMinimo, cfg.FovRadio * 0.5)
    end
    if cfg.FovPorDistancia and objetivoFijo then
        local dist = (objetivoFijo.Position - camara.CFrame.Position).Magnitude
        local factor = math.clamp(dist / cfg.FovPorDistanciaMax, 0, 1)
        fovEfectivo = cfg.FovRadio * (1 - factor * 0.6)
    end

    circulo.Visible = cfg.MostrarFOV
    circulo.Size = UDim2.fromOffset(fovEfectivo * 2, fovEfectivo * 2)
    borde.Color = cfg.Aimbot and COLOR_ACTIVO or COLOR_APAGADO

    actualizarESP()
    actualizarStuds()
    actualizarLineasJugador()
    actualizarSkeleton()
    actualizarOffScreen()
    actualizarHUDKills()
    actualizarTriggerbot()
    actualizarAutoFire()
    actualizarAntiAim(dt)
    actualizarAntiVoid()

    tAcumDeteccion = tAcumDeteccion + dt
    if tAcumDeteccion > 0.1 then
        actualizarDeteccionAimbots(tAcumDeteccion)
        tAcumDeteccion = 0
    end

    frames += 1
    tAcumFrame += dt
    if tAcumFrame >= 0.5 then
        fpsActual = math.floor(frames / tAcumFrame)
        frames = 0
        tAcumFrame = 0
    end

    tAcumHUD += dt
    if tAcumHUD > 0.3 then
        tAcumHUD = 0
        if cfg.MostrarHUDInfo then
            hudInfo.Visible = true
            local char = jugador.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local coords = hrp and string.format("X: %.0f  Y: %.0f  Z: %.0f", hrp.Position.X, hrp.Position.Y, hrp.Position.Z) or "X: -  Y: -  Z: -"
            local vel = hrp and math.floor(hrp.AssemblyLinearVelocity.Magnitude) or 0
            local ping = 0
            pcall(function()
                ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            hudInfo.Text = "FPS: " .. fpsActual .. "  |  Ping: " .. ping .. " ms\n"
                .. coords .. "\nVelocidad: " .. vel .. " studs/s"
        else
            hudInfo.Visible = false
        end
    end

    vigilarAutoRespawn()

    if not cfg.Aimbot then objetivoFijo = nil end

    if cfg.SonidoKill then actualizarMira() end

    local objetivo = nil
    if cfg.Aimbot then
        local puedeApuntar = not cfg.SoloClickDerecho
            or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        objetivo = elegirObjetivoAimbot()
        if objetivo then
            borde.Color = COLOR_OBJETIVO
            kill.modelo = objetivo.Parent
            kill.tMira = os.clock()

            if puedeApuntar then
                local suavidadReal = 0.5 + (cfg.Suavidad / 100) * 29.5

                local puntoFinal = puntoApuntar(objetivo)
                local destino = CFrame.lookAt(camara.CFrame.Position, puntoFinal)
                local t = math.clamp(dt * suavidadReal, 0, 1)
                t = aplicarCurva(t, cfg.CurvaSuavizado)

                if cfg.AimRestriccion < 180 then
                    local dot = camara.CFrame.LookVector:Dot(destino.LookVector)
                    local angulo = math.deg(math.acos(math.clamp(dot, -1, 1)))
                    if angulo > cfg.AimRestriccion then
                        t = t * (cfg.AimRestriccion / angulo)
                    end
                end

                if cfg.AntiShake then
                    t = t * (1 - cfg.AntiShakeForce * math.random() * 0.5)
                end

                camara.CFrame = camara.CFrame:Lerp(destino, t)
            end
        end
    end
    actualizarMarcador(objetivo)

    if cfg.UsarTrayectoria then
        setEstado("Bala " .. cfg._TrayectoriaIdx .. " → " .. (cfg.TrayectoriaSlots[cfg._TrayectoriaIdx] or "?"), T.acento)
    else
        setEstado(cfg.Aimbot and "Aimbot activo" or "Listo", cfg.Aimbot and T.amarillo or T.off)
    end
end)

-- =========================================================
-- AUTO-GUARDADO
-- =========================================================
task.spawn(function()
    while true do
        task.wait(15)
        guardarConfig()
    end
end)

print("[Panel v23.1] Cargado | Aimbot arreglado | Sin errores de registros")
