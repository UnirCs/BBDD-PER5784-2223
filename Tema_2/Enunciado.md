Se pide:
* Definir el XML Schema que podría ofrecer una pizzería. Un XML validado por este schema debería tener
    * Un listado de ‘pizza’ llamado ‘pizzas’.
    * Una ‘pizza’ tiene 3 atributos: ‘nombre’, ‘precio’ , ‘vegana’, y una secuencia de ‘ingrediente’ (de 1 a 5). Todos obligatorios.
    * Un ‘ingrediente’ tiene 1 atributo requerido: ‘nombre’.
* Definir un XML que sea correcto sintácticamente y que sea válido contra el esquema definido.

La entrega consta de 3 archivos:
* PizzaSchema.xsd: El archivo XSD con el schema.
* PizzaCatalog.xml: El archivo XML con las pizzas de una pizzería, validado contra el Schema creado.
* Evidencia: Imagen (jpg, png) usando el validador indicado en clase para comprobar que el XML es válido respecto al XSD.
