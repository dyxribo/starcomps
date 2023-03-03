package net.blaxstar.components {

import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.MouseEvent;

import net.blaxstar.style.Font;
import net.blaxstar.style.RGBA;
import net.blaxstar.style.Style;

import thirdparty.com.greensock.TweenLite;
import thirdparty.com.greensock.plugins.TintPlugin;
import thirdparty.com.greensock.plugins.TweenPlugin;
import thirdparty.org.osflash.signals.natives.NativeSignal;

/**
 * a simple button inspired by google material.
 * @author Deron D. (decamp.deron@gmail.com)
 */
public class Button extends Component {

	// static

	static public const GROUNDED:uint = 0;
	static public const DEPRESSED:uint = 1;
	static public const DEFAULT_WIDTH:uint = 50;
	static public const MIN_HEIGHT:uint = 10;

	// private
	private var _style:uint;
	private var _label:PlainText;
	private var _labelString:String;
	private var _background:Component;
	private var _backgroundOutline:Component;
	private var _glowColor:RGBA;
	private var _usingIcon:Boolean;
	private var _displayIcon:Icon;
	private var _data:Object;

	private var _onRollOver:NativeSignal;
	private var _onRollOut:NativeSignal;
	private var _onMouseDown:NativeSignal;
	private var _onMouseUp:NativeSignal;
	private var _onMouseClick:NativeSignal;


	public function Button(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, label:String = "BUTTON") {
		_labelString = label;

		super(parent, xpos, ypos);
	}

	/** INTERFACE net.blaxstar.components.IComponent ===================== */
	/**
	 * initializes the component by adding all the children
	 * and committing the visual changes to be written on the next frame.
	 * created to be overridden.
	 */
	override public function init():void {
		_width_ = DEFAULT_WIDTH;
		_height_ = MIN_HEIGHT;
		_style = 0;
		buttonMode = true;
		useHandCursor = true;

		_onRollOver = new NativeSignal(this, MouseEvent.ROLL_OVER, MouseEvent);
		_onRollOut = new NativeSignal(this, MouseEvent.ROLL_OUT, MouseEvent);
		_onMouseDown = new NativeSignal(this, MouseEvent.MOUSE_DOWN, MouseEvent);
		_onMouseUp = new NativeSignal(this, MouseEvent.MOUSE_UP, MouseEvent);
		_onMouseClick = new NativeSignal(this, MouseEvent.CLICK, MouseEvent);

		super.init();
	}

	/**
	 * initializes and adds all required children of the component.
	 */
	override public function addChildren():void {
		_background = new Component(this);
		_backgroundOutline = new Component(this);
		_label = new PlainText(this, 0, 0, _labelString);
		_background.width = _width_;
		_background.height = _height_;
		_label.format(Font.BUTTON);
		_glowColor = Style.GLOW;
		TweenPlugin.activate([TintPlugin]);
		commit();
	}

	/**
	 * (re)draws the component and applies any pending visual changes.
	 */
	override public function draw(e:Event = null):void {
		if (!_usingIcon) {
			_width_ = _background.width + (PADDING * 2);
			_height_ = _background.height + (PADDING * 2);
			_backgroundOutline.width = _width_;
			_backgroundOutline.height = _height_;
			_label.move((_width_ / 2) - (_label.width / 2), (_height_ / 2) - (_label.height / 2));
		} else {
			_background.width = _width_;
			_background.height = _height_;
			_backgroundOutline.width = _width_;
			_backgroundOutline.height = _height_;

			_displayIcon.isShowingBounds = true;
		}

		drawBG();

		_onMouseDown.add(onMouseDown);
		_onRollOver.add(onRollOver);
		onDraw.dispatch();
	}

	/** END INTERFACE ===================== */

	// public

	public function addClickListener(delegate:Function):void {
		if (!_onMouseClick) _onMouseClick = new NativeSignal(this, MouseEvent.CLICK, MouseEvent);
		_onMouseClick.add(delegate);
	}

	// private

	private function drawBG():void {
		_background.graphics.clear();
		_backgroundOutline.graphics.clear();
		filters = [];

		fillBG();
		if (_style != DEPRESSED) drawBGOutline();
	}

	private function fillBG():void {
		_background.graphics.beginFill(_glowColor.value);
		if (!_usingIcon) _background.graphics.drawRoundRect(0, 0, _width_, _height_, 7);
		else _background.graphics.drawRoundRect(0, 0, _width_, _height_, 7, 7);
		_background.graphics.endFill();
		_background.alpha = 0;

	}

	private function drawBGOutline():void {
		_backgroundOutline.graphics.lineStyle(1, Style.SECONDARY.value, 1, true);
		if (!_usingIcon) _backgroundOutline.graphics.drawRoundRect(0, 0, _width_, _height_, 6);
		else _backgroundOutline.graphics.drawRoundRect(0, 0, _width_, _height_, 7, 7);
	}

	// getters/setters

	public function set icon(val:String):void {
		_usingIcon = true;
		removeChild(_label);
		_displayIcon = new Icon(this);
		_displayIcon.setSVGXML(val);
		_displayIcon.addEventListener('iconLoaded', onIconLoaded);
		_width_ = 32;
		_height_ = 32;
		_style = GROUNDED;
		draw();
	}

	private function onIconLoaded(event:Event):void {
		_displayIcon.removeEventListener('iconLoaded', onIconLoaded);
		_displayIcon.move(((_width_/2) - (_displayIcon.width/2)), ((_height_/2) - (_displayIcon.height/2)));
	}

	public function getIcon():Icon {
		return _displayIcon;
	}

	public function get style():uint {
		return _style;
	}

	public function set style(val:uint):void {
		_style = val;
		commit();
	}

	public function get label():String {
		return _labelString;
	}

	public function set label(val:String):void {
		_labelString = val;
		commit();
	}

	public function set glowColor(val:RGBA):void {
		_glowColor = val;
		commit();
	}

	public function get onClick():NativeSignal {
		return _onMouseClick;
	}

	public function get data():Object {
		return _data;
	}

	public function set data(val:Object):void {
		_data = val;
	}

	// delegate functions

	private function onMouseDown(e:MouseEvent = null):void {
		_onMouseDown.remove(onMouseDown);
		_onMouseUp.add(onMouseUp);
		_onRollOut.add(onMouseUp);
		TweenLite.to(_background, 0.3, {tint: _glowColor.shade().value});
	}

	private function onMouseUp(e:MouseEvent = null):void {
		_onMouseUp.remove(onMouseUp);
		_onRollOut.remove(onMouseUp);
		_onMouseDown.add(onMouseDown);
		TweenLite.to(_background, 0.3, {tint: _glowColor.value});
	}

	private function onRollOver(e:MouseEvent = null):void {
		_onRollOver.remove(onRollOver);
		_onRollOut.add(onRollOut);
		TweenLite.to(_background, 0.3, {alpha: .1});
	}

	private function onRollOut(e:MouseEvent = null):void {
		_onRollOut.remove(onRollOut);
		_onRollOver.add(onRollOver);
		TweenLite.to(_background, 0.3, {alpha: 0});
	}

	override public function destroy(e:Event = null):void {
		_onRollOver.removeAll();
		_onRollOut.removeAll();
		_onMouseDown.removeAll();
		_onMouseUp.removeAll();
		_onMouseClick.removeAll();
	}
}
}