import wollok.game.*

object arquero {

	var property position = new Position(x = 25, y = 28)
	const posicionesFinales = [ new Position(x = 21, y = 32), new Position(x = 17, y = 33), new Position(x = 25, y = 28), new Position(x = 27, y = 31), new Position(x = 25, y = 32), new Position(x = 29, y = 33) ]
	const imagenes = [ "arqueroAbajoIzquierda.png", "arqueroArribaIzquierda.png", "arqueroAbajoCentro.png", "arqueroArribaCentro.png", "arqueroAbajoDerecha.png", "arqueroArribaDerecha.png" ]
	var property image = "arqueroAbajoCentro.png"

	method posicionFinal(numero) = posicionesFinales.get(numero - 1)

	method posicionInicial() {
		position = new Position(x = 25, y = 28)
		image = "arqueroAbajoCentro.png"
	}

	method validarPosicion(numeroPosicion) = position.y() < self.posicionFinal(numeroPosicion).y()

	method nuevaPosicion(numero) {
		image = imagenes.get(numero - 1)
		return posicionesFinales.get(numero - 1)
	}

	method devolverMensajeDisparo(isGol) = if (isGol) "No atajaste" else "Atajada Fenomenal"

	method gano(goles) = goles < 3

	method festejar(isGol) = if (!isGol) "atajada.mp3" else "fallo.mp3"

}

object pelota {

	var property position = new Position(x = 29, y = 18)
	const posicionesFinales = [ new Position(x = 20, y = 33), new Position(x = 20, y = 45), new Position(x = 29, y = 32), new Position(x = 29, y = 45), new Position(x = 38, y = 33), new Position(x = 38, y = 45) ]
	const posicionParcialX = [ -2, -2, 0, 0, 2, 2 ]
	const posicionParcialY = [ 3, 6, 2, 5, 3, 6 ]

	method image() = "pelota.png"

	method validarPosicion(numeroPosicion) = position.y() < (self.posicionFinal(numeroPosicion).y() - 3)

	method posicionInicial() {
		position = new Position(x = 29, y = 18)
	}

	method posicionFinal(numero) = posicionesFinales.get(numero - 1)

	method nuevaPosicion(numero) = new Position(x = position.x() + posicionParcialX.get(numero - 1), y = position.y() + posicionParcialY.get(numero - 1))

	method devolverMensajeDisparo(isGol) = if (isGol) "Gol!!!!!!!!!!" else "Fallaste!!!!!"

	method gano(goles) = goles >= 3

	method festejar(isGol) = if (isGol) "gol.wav" else "fallo.mp3"

}

object pateador {

	var property position = new Position(x = 19, y = 17)

	method image() = "jugador.png"

	method validarPosicion(numeroPosicion) = position.y() < (self.posicionFinal(numeroPosicion).y() - 3)

	method posicionInicial() {
		position = new Position(x = 19, y = 17)
	}

	method posicionFinal(numero) = new Position(x = 5, y = 5)

	method nuevaPosicion(numero) = new Position(x = position.x() + 1, y = position.y() + 1)

}

object ronda {

	var property usuario = new Jugador(rol = pelota)
	var property computadora = new Computadora(rol = arquero)
	var property ladoUsuario = null
	var property ladoComputadora = null
	var property estaEnJuego = false

	method modificarCriterio() {
		computadora.criterio(computadora.devolverCriterio())
	}

	method iniciarRoles(objeto) {
		usuario.rol(objeto.rolUsuario())
		computadora.rol(objeto.rolComputadora())
	}

	method devolverLado() = computadora.criterio().elegirLado()

	method isGol() = (ladoUsuario != ladoComputadora)

	method actualizarTablero() {
		usuario.disparo()
		if (self.isGol()) usuario.meterGol()
	}

	method reinciciarTablero() {
		usuario.reinciciarTablero()
	}

	method esFinDeJuego() = usuario.disparos() == 5

	method gano() = usuario.rol().gano(usuario.goles())

	method festejar() = usuario.rol().festejar(self.isGol())

}

class Jugador {

	var property rol
	var property goles = 0
	var property disparos = 0

	method disparo() {
		disparos += 1
	}

	method meterGol() {
		goles += 1
	}

	method reinciciarTablero() {
		goles = 0
		disparos = 0
	}

}

class Computadora inherits Jugador {

	var property criterio = self.devolverCriterio()

	method devolverCriterio() = [ mismoLado, siempreDistinto, ladoALado, ladoYCentro ].anyOne()

}

/* ========== Criterios de la computadora =============== */
class Criterio {

	method cualquierLado() = [ 1, 2, 3, 4, 5, 6 ].anyOne()

	method elegirLado() = self.cualquierLado()

}

object mismoLado inherits Criterio {

	var property lado = null

	override method elegirLado() {
		if (lado == null) lado = super()
		return lado
	}

}

object siempreDistinto inherits Criterio {

}

object ladoALado inherits Criterio {

	var property lado = self.izquierda()
	var property ladoSiguiente = self.derecha()

	method avanzarLado() {
		const temporal = lado
		lado = ladoSiguiente
		ladoSiguiente = temporal
	}

	override method elegirLado() {
		self.avanzarLado()
		return lado
	}

	method izquierda() = [ 1, 2 ].anyOne()

	method derecha() = [ 5, 6 ].anyOne()

}

object ladoYCentro inherits Criterio {

	var property lado = self.aLosLados()
	var disparos = 0

	override method elegirLado() {
		if (self.disparosMenoresA2()) {
			disparos += 1
			return lado
		}
		self.reiniciarCriterio()
		return self.centro()
	}

	method disparosMenoresA2() = disparos < 2

	method reiniciarCriterio() {
		disparos = 0
		lado = self.aLosLados()
	}

	method aLosLados() = [ 1, 2, 5, 6 ].anyOne()

	method centro() = [ 3, 4 ].anyOne()

}

/* ========== Elecciones del juego =============== */
object score {

	var property usuario = ronda.usuario()
	var property position = new Position(x = 7, y = 40)

	method text() = "Goles: " + usuario.goles().toString()

	method posicionInicial() {
	}

}

object numeroDeRonda {

	var property usuario = ronda.usuario()
	var property position = new Position(x = 46, y = 40)

	method text() = "Ronda: " + self.getNumeroRonda().toString()

	method getNumeroRonda() {
		return (usuario.disparos() + 1).min(5)
	}

	method posicionInicial() {
	}

}

object mostrarResultadoDelDisparo {

	var property rondaActual = ronda
	var property position = new Position(x = 26, y = 48)

	method isPateador() = (ronda.usuario().rol().toString() == "pelota")

	method text() = rondaActual.usuario().rol().devolverMensajeDisparo(ronda.isGol())

	method posicionInicial() {
	}

}

object ganaste {

	var property position = new Position(x = 4, y = 14)

	method image() = "ahoraQue.jpg"

	method posicionInicial() {
	}

}

object perdiste {

	var property position = new Position(x = 4, y = 14)

	method image() = "perdiste.jpg"

	method posicionInicial() {
	}

}

class Contenido {

	var property position
	var property image

	method posicionInicial() {
	}

}

const comienzo = new Contenido(position = new Position(x = 7, y = 12), image = "comienzo.jpg")

class Eleccion {

	var property rolUsuario
	var property rolComputadora

	method devolverAudio() = if (rolUsuario.toString() == "pelota") "meeeeesi.mp3" else "loSientoPeroTeComoHermano.mp3"

}

const eleccionPateador = new Eleccion(rolUsuario = pelota, rolComputadora = arquero)

const eleccionArquero = new Eleccion(rolUsuario = arquero, rolComputadora = pelota)

