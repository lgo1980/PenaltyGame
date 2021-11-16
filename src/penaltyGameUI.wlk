import modelos.*
import wollok.game.*

object penaltyGameUI {

	method configuracionInicial() {
		game.title("Penalty Game")
		game.height(60)
		game.width(60)
		game.cellSize(10)
		game.boardGround("fondo nuevo.png")
	}

	method iniciarEscenario() {
		game.addVisual(comienzo)
		self.configurarTeclasMenu()
	}

	method configurarTeclasMenu() {
		keyboard.a().onPressDo({ self.iniciarJuego(eleccionPateador)})
		keyboard.b().onPressDo({ self.iniciarJuego(eleccionArquero)})
		keyboard.r().onPressDo({ self.reiniciarJuego()})
		keyboard.t().onPressDo({ game.stop()})
	}

	method configurarTeclasJuego() {
		keyboard.num1().onPressDo({ self.ejecutarRemate(1)})
		keyboard.num2().onPressDo({ self.ejecutarRemate(2)})
		keyboard.num3().onPressDo({ self.ejecutarRemate(3)})
		keyboard.num4().onPressDo({ self.ejecutarRemate(4)})
		keyboard.num5().onPressDo({ self.ejecutarRemate(5)})
		keyboard.num6().onPressDo({ self.ejecutarRemate(6)})
	}

	method iniciarJuego(objeto) {
		if (game.hasVisual(comienzo)) {
			self.mostrarOpcionesConMusica(objeto.devolverAudio(), 4000, null)
			game.addVisual(arquero)
			game.addVisual(pelota)
			game.addVisual(pateador)
			ronda.iniciarRoles(objeto)
			game.addVisual(score)
			game.addVisual(numeroDeRonda)
			game.removeVisual(comienzo)
			ronda.estaEnJuego(true)
			self.configurarTeclasJuego()
		}
	}

	method ejecutarRemate(numero) {
		if (ronda.estaEnJuego()) {
			ronda.ladoUsuario(numero)
			ronda.ladoComputadora(ronda.devolverLado())
			self.recorridoPelotaYArquero()
		}
	}

	method movimientoObjeto(objeto, numero) {
		if (objeto.validarPosicion(numero)) objeto.position(objeto.nuevaPosicion(numero)) else {
			objeto.position(objeto.posicionFinal(numero))
			game.removeTickEvent(objeto.toString())
		}
	}

	method reiniciarJuego() {
		game.allVisuals().forEach{ objeto => objeto.posicionInicial()}
		game.clear()
		ronda.modificarCriterio()
		ronda.estaEnJuego(false)
		ronda.reinciciarTablero()
		self.iniciarEscenario()
	}

	method recorridoPelotaYArquero() {
		game.onTick(1, ronda.usuario().rol().toString(), { self.movimientoObjeto(ronda.usuario().rol(), ronda.ladoUsuario())})
		game.onTick(1, ronda.computadora().rol().toString(), { self.movimientoObjeto(ronda.computadora().rol(), ronda.ladoComputadora())})
		ronda.estaEnJuego(false)
		game.onTick(250, "resultado", { self.verificarResultadoDelDisparo()})
	}

	method verificarResultadoDelDisparo() {
		game.removeTickEvent("resultado")
		ronda.actualizarTablero()
		game.addVisual(mostrarResultadoDelDisparo)
		self.mostrarOpcionesConMusica(ronda.festejar(), 2000, null)
		self.validarEstadoJuego()
	}

	method validarEstadoJuego() {
		if (!ronda.esFinDeJuego()) game.onTick(2000, "reinicio", { self.reiniciarDisparo() }) else if (!ronda.gano()) self.perder() else self.ganar()
	}

	method mostrarOpcionesConMusica(sonido, demora, pantalla) {
		game.sound(sonido).play()
		game.schedule(demora, {
		})
		if (pantalla != null) {
			game.addVisual(pantalla)
			ronda.estaEnJuego(false)
		}
	}

	method perder() {
		self.mostrarOpcionesConMusica("perdiste.mp3", 9000, perdiste)
	}

	method ganar() {
		self.mostrarOpcionesConMusica("ganaste.mp3", 9000, ganaste)
	}

	method reiniciarDisparo() {
		game.removeTickEvent("reinicio")
		game.removeVisual(mostrarResultadoDelDisparo)
		ronda.estaEnJuego(true)
		[ arquero, pelota ].forEach{ objeto => objeto.posicionInicial()}
	}

}

