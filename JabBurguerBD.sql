-- Forzar la desconexión de todos los usuarios de la base de datos existente y eliminarla si existe
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'JabBurgerDB')
BEGIN
    ALTER DATABASE JabBurgerDB
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;  -- Configura la base de datos en modo de un solo usuario, eliminando conexiones activas
    DROP DATABASE JabBurgerDB;  -- Elimina la base de datos
END
GO

-- Creación de una nueva base de datos llamada 'JabBurgerDBB'
CREATE DATABASE JabBurgerDBB;
GO

-- Usar la base de datos recién creada para todas las operaciones siguientes
USE JabBurgerDBB;
GO

-- Tabla Cliente: Almacena información sobre los clientes
CREATE TABLE Cliente (
    ClienteID INT IDENTITY(1,1) PRIMARY KEY,  -- Identificador único, autoincremental
    Nombre VARCHAR(50) NOT NULL,  -- Nombre del cliente
    Apellido VARCHAR(50) NOT NULL,  -- Apellido del cliente
    Email VARCHAR(100) UNIQUE NOT NULL,  -- Email único para cada cliente
    Telefono VARCHAR(20),  -- Teléfono del cliente
    Direccion VARCHAR(100),  -- Dirección del cliente
    FechaRegistro DATE DEFAULT GETDATE(),  -- Fecha de registro con valor por defecto
    Estado VARCHAR(20) DEFAULT 'Activo'  -- Estado del cliente (por defecto 'Activo')
);

-- Tabla Empleado: Almacena información sobre los empleados
CREATE TABLE Empleado (
    EmpleadoID INT IDENTITY(1,1) PRIMARY KEY,  -- Identificador único, autoincremental
    Nombre VARCHAR(50) NOT NULL,  -- Nombre del empleado
    Rol VARCHAR(20) NOT NULL,  -- Rol del empleado (ej. Cajero, Cocinero)
    Telefono VARCHAR(20),  -- Teléfono del empleado
    Estado VARCHAR(20),  -- Estado del empleado (ej. Activo, Inactivo)
    FechaContratacion DATE,  -- Fecha de contratación
    Salario DECIMAL(10, 2)  -- Salario del empleado
);

-- Tabla ProveedorPago: Almacena proveedores de métodos de pago
CREATE TABLE ProveedorPago (
    ProveedorPagoID INT IDENTITY(1,1) PRIMARY KEY,  -- Identificador único, autoincremental
    Nombre VARCHAR(50) NOT NULL,  -- Nombre del proveedor de pago (ej. Visa, PayPal)
    TipoServicio VARCHAR(100) NOT NULL,  -- Tipo de servicio (Tarjetas, Pago en línea, etc.)
    Contacto VARCHAR(50),  -- Información de contacto
    Telefono VARCHAR(20)  -- Teléfono de contacto
);

-- Tabla Almacen: Almacena información sobre los almacenes
CREATE TABLE Almacen (
    AlmacenID INT IDENTITY(1,1) PRIMARY KEY,  -- Identificador único, autoincremental
    Nombre VARCHAR(50) NOT NULL,  -- Nombre del almacén
    Direccion VARCHAR(100),  -- Dirección del almacén
    Responsable VARCHAR(50),  -- Persona responsable del almacén
    FechaCreacion DATE DEFAULT GETDATE()  -- Fecha de creación del almacén
);

-- Tabla CategoriaProducto: Almacena categorías de productos
CREATE TABLE CategoriaProducto (
    CategoriaProductoID INT IDENTITY(1,1) PRIMARY KEY,  -- Identificador único, autoincremental
    Nombre VARCHAR(50) NOT NULL  -- Nombre de la categoría (ej. Hamburguesas, Bebidas)
);

-- Tabla Producto: Almacena información sobre productos
CREATE TABLE Producto (
    ProductoID INT IDENTITY(1,1) PRIMARY KEY,  -- Identificador único, autoincremental
    Nombre VARCHAR(50) NOT NULL,  -- Nombre del producto (ej. Hamburguesa Clásica)
    Descripcion TEXT,  -- Descripción detallada del producto
    Precio DECIMAL(10, 2) NOT NULL,  -- Precio del producto
    FechaVencimiento DATE,  -- Fecha de vencimiento del producto (si aplica)
    UnidadMedida VARCHAR(20),  -- Unidad de medida (ej. unidad, litros)
    FechaIngreso DATE DEFAULT GETDATE(),  -- Fecha de ingreso del producto en el sistema
    Stock INT NOT NULL,  -- Cantidad en stock
    CategoriaProductoID INT,  -- Relación con la tabla CategoriaProducto
    AlmacenID INT,  -- Relación con la tabla Almacen
    FOREIGN KEY (CategoriaProductoID) REFERENCES CategoriaProducto(CategoriaProductoID),  -- Llave foránea con la tabla CategoriaProducto
    FOREIGN KEY (AlmacenID) REFERENCES Almacen(AlmacenID)  -- Llave foránea con la tabla Almacen
);

-- Tabla Oferta: Almacena ofertas de descuentos para productos
CREATE TABLE Oferta (
    OfertaID INT IDENTITY(1,1) PRIMARY KEY,  -- Identificador único, autoincremental
    Descripcion VARCHAR(100) NOT NULL,  -- Descripción de la oferta
    Condiciones TEXT,  -- Detalles o condiciones de la oferta
    PorcentajeDescuento DECIMAL(5, 2) CHECK (PorcentajeDescuento BETWEEN 0 AND 100),  -- Porcentaje de descuento entre 0 y 100
    FechaInicio DATE NOT NULL,  -- Fecha de inicio de la oferta
    FechaFin DATE NOT NULL  -- Fecha de fin de la oferta
);

-- Tabla ProductoOferta: Relación muchos a muchos entre productos y ofertas
CREATE TABLE ProductoOferta (
    ProductoID INT,  -- Relación con la tabla Producto
    OfertaID INT,  -- Relación con la tabla Oferta
    PRIMARY KEY (ProductoID, OfertaID),  -- Clave primaria compuesta de ProductoID y OfertaID
    FOREIGN KEY (ProductoID) REFERENCES Producto(ProductoID),  -- Llave foránea con la tabla Producto
    FOREIGN KEY (OfertaID) REFERENCES Oferta(OfertaID)  -- Llave foránea con la tabla Oferta
);

-- Tabla Factura: Almacena la cabecera de facturas
CREATE TABLE Factura (
    FacturaID VARCHAR(50) PRIMARY KEY,  -- Identificador único (no autoincremental)
    FechaEmision DATE,  -- Fecha de emisión de la factura
    Moneda VARCHAR(3) DEFAULT 'PEN',  -- Tipo de moneda (ej. PEN, USD)
    NumeroFactura VARCHAR(20) UNIQUE,  -- Número único de factura
    RucEmpresa VARCHAR(20),  -- RUC de la empresa emisora
    RazonSocialEmpresa VARCHAR(100),  -- Razón social de la empresa emisora
    RucCliente VARCHAR(20),  -- RUC del cliente
    RazonSocialCliente VARCHAR(100),  -- Razón social del cliente
    DireccionCliente VARCHAR(150),  -- Dirección del cliente
    Cajero VARCHAR(50),  -- Nombre del cajero que emitió la factura
    SubTotal DECIMAL(10, 2),  -- Subtotal antes de impuestos
    IGV DECIMAL(10, 2),  -- Impuesto (ej. IGV)
    Total DECIMAL(10, 2)  -- Total de la factura
);

-- Tabla Boleta: Almacena la cabecera de boletas
CREATE TABLE Boleta (
    BoletaID INT PRIMARY KEY,  -- Identificador único (no autoincremental)
    FechaEmision DATE,  -- Fecha de emisión de la boleta
    Total DECIMAL(10, 2),  -- Total de la boleta
    Moneda VARCHAR(3) DEFAULT 'PEN',  -- Tipo de moneda (ej. PEN, USD)
    NumeroBoleta VARCHAR(20) UNIQUE  -- Número único de la boleta
);

-- Tabla TransaccionPago: Almacena las transacciones de pago
CREATE TABLE TransaccionPago (
    TransaccionPagoID INT IDENTITY(1,1) PRIMARY KEY,  -- Identificador único, autoincremental
    FechaTransaccion DATE,  -- Fecha de la transacción
    ProveedorPagoID INT,  -- Relación con la tabla ProveedorPago
    TipoComprobante VARCHAR(20),  -- Tipo de comprobante (Factura o Boleta)
    MetodoPago VARCHAR(50),  -- Método de pago (Tarjeta, PayPal, etc.)
    Monto DECIMAL(10, 2),  -- Monto de la transacción
    ReferenciaPago VARCHAR(50),  -- Número de referencia del pago
    FacturaID VARCHAR(50),  -- Relación opcional con la tabla Factura
    BoletaID INT,  -- Relación opcional con la tabla Boleta
    FOREIGN KEY (ProveedorPagoID) REFERENCES ProveedorPago(ProveedorPagoID),  -- Llave foránea con la tabla ProveedorPago
    FOREIGN KEY (FacturaID) REFERENCES Factura(FacturaID),  -- Llave foránea con la tabla Factura
    FOREIGN KEY (BoletaID) REFERENCES Boleta(BoletaID)  -- Llave foránea con la tabla Boleta
);

-- Tabla Pedido: Almacena los pedidos realizados por los clientes
CREATE TABLE Pedido (
    PedidoID INT IDENTITY(1,1) PRIMARY KEY,  -- Identificador único, autoincremental
    Fecha DATETIME NOT NULL DEFAULT GETDATE(),  -- Fecha del pedido, por defecto la fecha actual
    Estado VARCHAR(20) NOT NULL,  -- Estado del pedido (ej. Completado, Pendiente)
    MontoTotal DECIMAL(10, 2) NOT NULL,  -- Monto total del pedido
    ClienteID INT NOT NULL,  -- Relación con la tabla Cliente
    EmpleadoID INT,  -- Relación opcional con la tabla Empleado
    ProveedorPagoID INT,  -- Relación con la tabla ProveedorPago
    TipoPedido VARCHAR(50),  -- Tipo de pedido (En línea, En el local, A domicilio)
    MetodoEntrega VARCHAR(50),  -- Método de entrega (Recogido, Entregado)
    TransaccionPagoID INT,  -- Relación con la tabla TransaccionPago
    FOREIGN KEY (ClienteID) REFERENCES Cliente(ClienteID),  -- Llave foránea con la tabla Cliente
    FOREIGN KEY (EmpleadoID) REFERENCES Empleado(EmpleadoID),  -- Llave foránea con la tabla Empleado
    FOREIGN KEY (ProveedorPagoID) REFERENCES ProveedorPago(ProveedorPagoID),  -- Llave foránea con la tabla ProveedorPago
    FOREIGN KEY (TransaccionPagoID) REFERENCES TransaccionPago(TransaccionPagoID)  -- Llave foránea con la tabla TransaccionPago
);

-- Tabla DetallePedido: Almacena los detalles de cada pedido (productos pedidos)
CREATE TABLE DetallePedido (
    DetallePedidoID INT IDENTITY(1,1) PRIMARY KEY,  -- Identificador único, autoincremental
    PedidoID INT NOT NULL,  -- Relación con la tabla Pedido
    ProductoID INT NOT NULL,  -- Relación con la tabla Producto
    Cantidad INT NOT NULL,  -- Cantidad del producto
    PrecioUnitario DECIMAL(10, 2) NOT NULL,  -- Precio unitario del producto
    OfertaID INT,  -- Relación opcional con la tabla Oferta para aplicar descuentos
    FOREIGN KEY (PedidoID) REFERENCES Pedido(PedidoID),  -- Llave foránea con la tabla Pedido
    FOREIGN KEY (ProductoID) REFERENCES Producto(ProductoID),  -- Llave foránea con la tabla Producto
    FOREIGN KEY (OfertaID) REFERENCES Oferta(OfertaID)  -- Llave foránea con la tabla Oferta
);

-- Activar IDENTITY_INSERT para CategoriaProducto
SET IDENTITY_INSERT CategoriaProducto ON;
INSERT INTO CategoriaProducto (CategoriaProductoID, Nombre) VALUES
(1, 'Hamburguesas'),
(2, 'Bebidas'),
(3, 'Acompañamientos'),
(4, 'Postres');
SET IDENTITY_INSERT CategoriaProducto OFF;

-- Activar IDENTITY_INSERT para Almacen
SET IDENTITY_INSERT Almacen ON;
INSERT INTO Almacen (AlmacenID, Nombre, Direccion, Responsable) VALUES
(1, 'Almacén Principal', 'Av. Siempre Viva 123, Lima', 'Juan Perez'),
(2, 'Almacén Secundario', 'Jr. Independencia 456, Callao', 'Maria López');
SET IDENTITY_INSERT Almacen OFF;

-- Activar IDENTITY_INSERT para ProveedorPago
SET IDENTITY_INSERT ProveedorPago ON;
INSERT INTO ProveedorPago (ProveedorPagoID, Nombre, TipoServicio, Contacto, Telefono) VALUES
(1, 'Visa', 'Tarjetas de Crédito/Débito', 'Contacto Visa', '987654321'),
(2, 'PayPal', 'Pago en línea', 'Contacto PayPal', '998877665'),
(3, 'Mastercard', 'Tarjetas de Crédito/Débito', 'Contacto Mastercard', '923456789');
SET IDENTITY_INSERT ProveedorPago OFF;

-- Activar IDENTITY_INSERT para Cliente
SET IDENTITY_INSERT Cliente ON;
INSERT INTO Cliente (ClienteID, Nombre, Apellido, Email, Telefono, Direccion) VALUES
(1, 'Carlos', 'Ramírez', 'carlos.ramirez@example.com', '999888777', 'Av. Grau 123, Lima'),
(2, 'Lucía', 'Pérez', 'lucia.perez@example.com', '999777666', 'Jr. Tarapacá 456, Callao'),
(3, 'Roberto', 'Torres', 'roberto.torres@example.com', '988777666', 'Av. Salaverry 789, Lima');
SET IDENTITY_INSERT Cliente OFF;

-- Activar IDENTITY_INSERT para Empleado
SET IDENTITY_INSERT Empleado ON;
INSERT INTO Empleado (EmpleadoID, Nombre, Rol, Telefono, Estado, FechaContratacion, Salario) VALUES
(1, 'Ana', 'Cajero', '987654321', 'Activo', '2023-01-15', 1200.00),
(2, 'José', 'Cocinero', '998877665', 'Activo', '2023-02-20', 1500.00),
(3, 'María', 'Mesero', '923456789', 'Activo', '2023-03-10', 1100.00);
SET IDENTITY_INSERT Empleado OFF;

-- Activar IDENTITY_INSERT para Producto
SET IDENTITY_INSERT Producto ON;
INSERT INTO Producto (ProductoID, Nombre, Descripcion, Precio, FechaVencimiento, UnidadMedida, Stock, CategoriaProductoID, AlmacenID) VALUES
-- Hamburguesas
(1, 'Hamburguesa Clásica', 'Hamburguesa con queso, lechuga, tomate y salsas.', 18.00, '2024-12-31', 'unidad', 50, 1, 1),
(2, 'Hamburguesa Doble', 'Doble carne con queso cheddar y salsas.', 25.00, '2024-12-31', 'unidad', 30, 1, 1),
(3, 'Hamburguesa Vegana', 'Hamburguesa con carne vegetal y verduras.', 22.00, '2024-12-31', 'unidad', 20, 1, 1),
(4, 'Hamburguesa BBQ', 'Hamburguesa con salsa BBQ y tocino.', 28.00, '2024-12-31', 'unidad', 25, 1, 1),
(5, 'Hamburguesa de Pollo', 'Hamburguesa con pechuga de pollo y salsas.', 20.00, '2024-12-31', 'unidad', 40, 1, 1),
(6, 'Hamburguesa Picante', 'Hamburguesa con salsa picante.', 26.00, '2024-12-31', 'unidad', 15, 1, 1),
(7, 'Hamburguesa de Pescado', 'Hamburguesa con filete de pescado y salsas.', 24.00, '2024-12-31', 'unidad', 10, 1, 1),
-- Bebidas
(8, 'Gaseosa Coca Cola 500ml', 'Gaseosa refrescante.', 5.00, '2025-01-01', 'unidad', 200, 2, 1),
(9, 'Gaseosa Inca Kola 500ml', 'Gaseosa tradicional peruana.', 5.00, '2025-01-01', 'unidad', 150, 2, 1),
(10, 'Agua Mineral 500ml', 'Agua sin gas.', 3.00, '2025-01-01', 'unidad', 150, 2, 2),
(11, 'Jugo de Naranja', 'Jugo natural de naranja.', 7.00, '2024-12-31', 'unidad', 80, 2, 2),
(12, 'Cerveza Artesanal 330ml', 'Cerveza artesanal peruana.', 12.00, '2025-06-01', 'unidad', 100, 2, 2),
-- Acompañamientos
(13, 'Papas Fritas', 'Papas fritas crujientes.', 8.00, '2024-12-31', 'unidad', 100, 3, 1),
(14, 'Papas Rústicas', 'Papas rústicas con especias.', 10.00, '2024-12-31', 'unidad', 60, 3, 1),
(15, 'Ensalada', 'Ensalada fresca con aderezo.', 10.00, '2024-12-31', 'unidad', 40, 3, 2),
(16, 'Aros de Cebolla', 'Aros de cebolla empanizados y fritos.', 9.00, '2024-12-31', 'unidad', 50, 3, 1),
(17, 'Nuggets de Pollo', 'Nuggets de pollo empanizados.', 12.00, '2024-12-31', 'unidad', 70, 3, 1),
-- Postres
(18, 'Helado de Vainilla', 'Postre frío sabor vainilla.', 12.00, '2024-12-31', 'unidad', 50, 4, 2),
(19, 'Brownie con Helado', 'Brownie de chocolate con helado.', 15.00, '2024-12-31', 'unidad', 30, 4, 2),
(20, 'Tarta de Manzana', 'Tarta de manzana con canela.', 14.00, '2024-12-31', 'unidad', 25, 4, 2);
SET IDENTITY_INSERT Producto OFF;

-- Activar IDENTITY_INSERT para Oferta
SET IDENTITY_INSERT Oferta ON;
INSERT INTO Oferta (OfertaID, Descripcion, Condiciones, PorcentajeDescuento, FechaInicio, FechaFin) VALUES
(1, 'Descuento del 10% en Hamburguesas Clásicas', 'Válido hasta fin de mes', 10.00, '2024-09-01', '2024-09-30'),
(2, 'Descuento del 5% en Bebidas', 'Válido solo en pedidos mayores a S/20', 5.00, '2024-09-01', '2024-12-31'),
(3, 'Descuento del 15% en Postres', 'Válido por el mes de aniversario', 15.00, '2024-09-01', '2024-09-30');
SET IDENTITY_INSERT Oferta OFF;

-- Insertar datos en ProductoOferta
INSERT INTO ProductoOferta (ProductoID, OfertaID) VALUES
(1, 1),  -- Hamburguesa Clásica con descuento del 10%
(8, 2),  -- Gaseosa Coca Cola con descuento del 5%
(9, 2),  -- Gaseosa Inca Kola con descuento del 5%
(18, 3),  -- Helado de Vainilla con descuento del 15%
(19, 3);  -- Brownie con Helado con descuento del 15%

-- Insertar una factura
INSERT INTO Factura (FacturaID, FechaEmision, Moneda, NumeroFactura, RucEmpresa, RazonSocialEmpresa, RucCliente, RazonSocialCliente, DireccionCliente, Cajero, SubTotal, IGV, Total)
VALUES ('FAC001', GETDATE(), 'PEN', 'F001-0001', '12345678901', 'Empresa SA', '987654321', 'Cliente A', 'Av. Lima 123', 'Ana', 45.00, 8.10, 50.00);

-- Insertar una boleta
INSERT INTO Boleta (BoletaID, FechaEmision, Total, Moneda, NumeroBoleta)
VALUES (1, GETDATE(), 30.00, 'PEN', 'B001-0001');

-- Insertar datos en TransaccionPago
SET IDENTITY_INSERT TransaccionPago ON;
INSERT INTO TransaccionPago (TransaccionPagoID, FechaTransaccion, ProveedorPagoID, TipoComprobante, MetodoPago, Monto, ReferenciaPago, FacturaID, BoletaID) VALUES
(1, GETDATE(), 1, 'Factura', 'Tarjeta de Crédito', 50.00, 'REF12345', 'FAC001', NULL),
(2, GETDATE(), 2, 'Boleta', 'PayPal', 30.00, 'REF98765', NULL, 1);
SET IDENTITY_INSERT TransaccionPago OFF;

-- Insertar datos en Pedido
SET IDENTITY_INSERT Pedido ON;
INSERT INTO Pedido (PedidoID, Fecha, Estado, MontoTotal, ClienteID, EmpleadoID, ProveedorPagoID, TipoPedido, MetodoEntrega, TransaccionPagoID) VALUES
(1, GETDATE(), 'Completado', 50.00, 1, 1, 1, 'En línea', 'Recogido', 1),
(2, GETDATE(), 'Completado', 30.00, 2, 2, 2, 'A domicilio', 'Entregado', 2);
SET IDENTITY_INSERT Pedido OFF;

-- Insertar datos en DetallePedido
SET IDENTITY_INSERT DetallePedido ON;
INSERT INTO DetallePedido (DetallePedidoID, PedidoID, ProductoID, Cantidad, PrecioUnitario, OfertaID) VALUES
(1, 1, 1, 2, 18.00, 1),  -- Pedido 1 con Hamburguesa Clásica
(2, 1, 8, 2, 5.00, 2),   -- Pedido 1 con Gaseosa Coca Cola
(3, 2, 2, 1, 25.00, NULL),  -- Pedido 2 con Hamburguesa Doble sin oferta
(4, 2, 6, 1, 3.00, 2);   -- Pedido 2 con Agua Mineral
SET IDENTITY_INSERT DetallePedido OFF;













