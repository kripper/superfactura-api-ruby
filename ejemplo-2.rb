#!/usr/bin/env ruby
# encoding: ISO-8859-1

# Ejemplo similar al ejemplo-1, pero ac� se obtienen adem�s el PDF, el PDF-Cedible y el XML desde SuperFactura.

require_relative 'SuperFacturaAPI/api'

# 1) Generar arreglo con datos del DTE

datos = {
	'Encabezado' => {
		'IdDoc' => {
			'TipoDTE' => 33,
			# 'FchEmis' => '2015-01-01', # Opcional
		},
		'Emisor' => {
			'RUTEmisor' => '99581150-2',
			# Los dem�s datos ser�n agregados por SuperFactura
		},
		'Receptor' => {
			'RUTRecep' => '1-9',
			'RznSocRecep' => 'Test',
			'GiroRecep' => 'Giro',
			'DirRecep' => 'Direcci�n',
			'CmnaRecep' => 'Comuna',
			'CiudadRecep' => 'Ciudad',
		},
		# 'Totales' ser� agregado por SuperFactura
	},
	'Detalles' => [
		{
			# 'NroLinDet' ser� agregado por SuperFactura
			'NmbItem' => 'Item 1',
			'DscItem' => 'Descripci�n del item 1',
			'QtyItem' => 3,
			'UnmdItem' => 'KG',
			'PrcItem' => 100
		},
		{
			'NmbItem' => 'Item 2',
			'DscItem' => 'Descripci�n del item 2',
			'QtyItem' => 5,
			'UnmdItem' => 'KG',
			'PrcItem' => 65
		}
	]
}

# 2) Usar API para generar y enviar el DTE al SII

api = SuperFacturaAPI.new('usuario@cliente.cl', 'mypassword')

resultado = api.SendDTE(
	datos,	# Datos del DTE
	'cer',	# Ambiente: 'pro' = producci�n y 'cer' = certificaci�n
	{		# El tercer argumento puede contener un arreglo con opciones
		'savePDF' => '/tmp/dte-123',	# Descarga y almacena el PDF
		'saveXML' => '/tmp/dte-123'		# Descarga y almacena el XML
	}
)

# 3) Procesar salida de la API

if resultado['ok']
	puts 'Folio: ' + resultado['folio']
else
	puts 'Error'
end
