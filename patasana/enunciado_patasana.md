# PataSana

PataSana es una red de clínicas veterinarias que nació en 2018 con una sede en el barrio
Chapinero de Bogotá, abrió en 2020 una segunda sede en Laureles, Medellín, en 2023 una tercera en
Granada, Cali, y en noviembre de 2025 una cuarta en Usaquén, de nuevo en Bogotá. Cada sede se
conoce por un nombre que no se repite en la red, y de ella interesa saber en qué ciudad está, su
dirección, su teléfono, su correo y la fecha en que abrió sus puertas. Hasta hoy todo se ha
manejado en hojas de cálculo: la recepción agenda las citas en un Excel compartido, los
veterinarios anotan los tratamientos en papel, el inventario de medicamentos se cuenta a mano
cada mes y nadie sabe con certeza qué clientes deben dinero.

En los últimos meses los problemas se volvieron imposibles de ignorar. Dos mascotas quedaron
agendadas con el mismo veterinario a la misma hora; se agendó una cita de control para un perro
que había fallecido semanas antes; la sede de Medellín se quedó sin omeprazol sin que nadie lo
notara; una factura se cobró dos veces y otra nunca se cobró; un auxiliar quedó registrado como el
veterinario que había hecho una cirugía; y la gerencia no logra responder preguntas tan simples
como cuánto facturó cada sede el mes pasado o qué clientes no han vuelto desde hace seis meses.
La directora general, Mariana Ortiz, ha decidido construir una base de datos que ponga orden en
todo esto, y te ha contratado para diseñarla e implementarla en PostgreSQL.

Todo el personal trabaja en una sola sede y ocupa un cargo. Los cargos que existen hoy son
director general, veterinario jefe, veterinario, recepcionista y auxiliar, pero la lista puede
crecer, y de cada cargo hay que saber si quien lo ocupa está habilitado para atender pacientes,
porque solo quienes tienen un cargo de veterinario pueden atender citas. De cada empleado se
guardan sus nombres, apellidos, documento de identidad (que no se puede repetir), un correo que
algunos no tienen pero que, si lo tienen, no puede pertenecer a otra persona, la fecha en que
ingresó y su salario, que siempre es mayor que cero. Casi todos tienen un jefe, que es a su vez
otro empleado de la red: la directora no responde a nadie, los veterinarios jefes de cada sede le
responden a ella y el resto del personal de cada sede le responde a su veterinario jefe. Cuando
alguien se retira no se borra, simplemente deja de estar activo. La directora quiere poder ver el
organigrama completo, con el nivel de cada persona y la cadena de mando que la conecta con ella,
y saber quiénes dependen, directa o indirectamente, de cualquier jefe.

Los clientes son los dueños de las mascotas. De cada uno se conoce su documento, que es único,
sus nombres y apellidos, un teléfono que es obligatorio porque es la única forma segura de
contactarlo, un correo opcional que tampoco puede repetirse entre clientes y que debe tener un
formato razonable, la ciudad donde vive y la fecha en que se registró, que si nadie la indica
es el día del registro. Un cliente puede tener varias mascotas, y la clínica debe decidir con
cuidado qué ocurre si alguien intenta eliminar a un cliente que tiene mascotas, porque con ellas
se iría toda su historia clínica.

Las mascotas pertenecen a una especie, como perro, gato, ave, conejo o reptil, y dentro de su
especie a una raza. El catálogo de especies y razas lo mantiene la clínica, y aunque el nombre de
una raza no se repite dentro de su especie, sí puede repetirse entre especies distintas: existe
el criollo de perro y el criollo de gato, y son razas diferentes. De cada mascota se registran su
nombre, su sexo (macho o hembra), su peso, que siempre es positivo y que en un periquito puede ser
de apenas unos pocos gramos, y su fecha de nacimiento, que nunca puede estar en el futuro pero que
a veces no se conoce, por ejemplo en los animales rescatados. Un mismo cliente no puede tener dos
mascotas vivas con el mismo nombre, aunque sí puede volver a usar el nombre de una que ya murió.
Cuando una mascota fallece se anota la fecha de su muerte, que no puede ser anterior a su
nacimiento, y a partir de ese momento no se le puede agendar ninguna cita. También se quiere
poder escribir observaciones libres sobre cada animal.

La clínica ofrece servicios como consulta general, consulta especializada, vacunación,
desparasitación, baño y peluquería, cirugía menor, esterilización, radiografía y hospitalización
por día. Cada servicio tiene un nombre que no se repite, una categoría (consulta, prevención,
estética, cirugía, diagnóstico, hospitalización), un precio en pesos colombianos que nunca es
negativo, una duración en minutos que siempre es positiva, y puede estar vigente o haberse dejado
de ofrecer. Los precios cambian de vez en cuando, por ejemplo cuando la gerencia decide subir en
un porcentaje todos los servicios de una categoría, y cada cambio de precio debe quedar
registrado con el precio anterior, el nuevo, el usuario que hizo el cambio y el momento en que lo
hizo.

Una cita reúne a una mascota, un veterinario, una sede y un servicio en una fecha y hora
determinadas, y puede llevar un motivo de consulta. La sede de la cita es la sede donde trabaja el
veterinario que la atiende. Cuando se agenda, la cita queda programada; después puede pasar a
atendida, cancelada o a no asistió, este último caso cuando la hora pasa y la mascota nunca
llegó. Un veterinario no puede tener dos citas a la misma fecha y hora, nunca puede asignarse una
cita a un empleado que no sea veterinario o que ya no esté activo, y si dos recepcionistas
intentan al mismo tiempo agendar el último horario libre de un veterinario, solo una de ellas
puede lograrlo. Para cada cita debe saberse cuándo se modificó por última vez.

PataSana maneja un catálogo de medicamentos como amoxicilina, meloxicam, ivermectina,
prazicuantel, vacunas antirrábica y triple felina, omeprazol, shampoo dermatológico, tramadol o
suero oral. Cada medicamento tiene un nombre que no se repite, una presentación (tableta,
frasco, dosis, cápsula, sobre), un precio unitario y una marca que indica si exige fórmula
médica. Cada sede lleva su propio inventario: por cada medicamento que maneja conoce su
existencia actual, que nunca puede ser negativa, y una existencia mínima por debajo de la cual
hay que hacer un pedido. No todas las sedes manejan todos los medicamentos, y la sede de Usaquén
todavía no tiene inventario. Cuando llega un pedido, lo recibido se suma a la existencia de la
sede si esta ya manejaba ese medicamento, y si no, se empieza a manejar con la cantidad recibida.
Se quiere conservar un registro de cada movimiento de inventario, y poder obtener en cualquier
momento qué medicamentos están por debajo del mínimo en cada sede y cuánto convendría pedir.

Durante una cita atendida el veterinario puede formular uno o varios medicamentos, indicando
para cada uno la cantidad, siempre positiva, y las indicaciones de uso. Un mismo medicamento no se
formula dos veces en la misma cita. Al formular, lo formulado se descuenta del inventario de la
sede donde ocurrió la cita, y si no hay existencias suficientes la formulación no puede
registrarse. Si en una misma atención se formulan varios medicamentos y uno de ellos no tiene
existencias, los demás deben poder registrarse de todas formas.

Cada cita atendida genera como máximo una factura, con su fecha de emisión y un estado que
empieza en pendiente y puede pasar a pagada o anulada. La factura se compone de líneas, cada una
con una descripción, una cantidad, un valor unitario y su subtotal: una línea por el servicio
prestado y una por cada medicamento formulado, al precio vigente. El total de la factura es la
suma de sus líneas, y si se elimina una factura sus líneas no tienen razón de existir. El cliente
puede pagar una factura en uno o varios abonos, cada uno con su fecha, su método de pago
(efectivo, tarjeta o transferencia) y un monto que siempre es positivo y que nunca puede superar
lo que falta por pagar. Cuando lo abonado cubre el total, la factura pasa a pagada. Las facturas
anuladas no reciben pagos, y una factura que ya tiene pagos no puede desaparecer del sistema. El
registro de una atención completa (marcar la cita como atendida, formular, descontar inventario,
facturar y recibir el pago) debe ocurrir completo o no ocurrir, de modo que un error a mitad de
camino no deje datos a medias.

No todo el personal debe ver ni hacer lo mismo. La administración puede consultarlo todo, también
lo que se cree en el futuro. La recepción registra y modifica clientes, mascotas y citas, consulta
los servicios, nunca borra nada y no puede ver los salarios de los empleados. Los veterinarios
consultan las mascotas y las citas, registran fórmulas y solo pueden cambiar el estado de una
cita, nada más de ella; además, cada veterinario solo debe ver las citas que le corresponden.

La gerencia, por su parte, necesita responder con facilidad preguntas como la agenda de citas
programadas con el teléfono del dueño, la historia clínica completa de cualquier mascota, el
estado de cuenta de cada factura con lo pagado y el saldo, los clientes que deben dinero, el
ingreso recaudado por sede, por mes y por método de pago, lo facturado por categoría de servicio,
los servicios más solicitados en cada sede, los veterinarios que más atienden, los clientes que
más gastan y los que no vuelven hace más de seis meses para enviarles un recordatorio, y las
próximas fechas de vacunación de cada mascota. Los ingresos mensuales por sede se consultan tanto
que conviene tenerlos precalculados, aunque se actualicen solo cuando se pida. Al final de cada
mes se hace un cierre que guarda, por sede, el ingreso recaudado, las citas atendidas, las citas a
las que no se asistió y el saldo pendiente de cobro.

Diseña e implementa la base de datos de PataSana.
