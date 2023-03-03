package net.blaxstar.components {
import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.events.Event;
import flash.events.MouseEvent;

import net.blaxstar.style.Style;

/**
	 * ...
	 * @author Deron Decamp
	 */
	// TODO (dyxribo, STARLIB-6): implement dropdown component
	public class Dropdown extends Component {

		private var _displayLabel:PlainText;
		private var _labelText:String;
		private var _dropdownButton:Button;
		private var _dropdownList:List;
		private var _selectedItem:ListItem;

		public function Dropdown(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0, initLabel:String="Select an Item") {
			_labelText = initLabel;
			super(parent, xpos, ypos);
		}
		
		/** INTERFACE net.blaxstar.components.IComponent ===================== */
		
		/**
		 * initializes the component by adding all the children and committing the visual changes to be written on the next frame. created to be overridden.
		 */
		override public function init():void {
			_width_ = 150;
			_height_ = 30;
			super.init();
		}
		/**
		 * base method for initializing and adding children of the component. created to be overridden.
		 */
		override public function addChildren():void {
			_displayLabel = new PlainText(this, 0, 0, _labelText);
			_displayLabel.width = _width_;
			_dropdownButton = new Button(this,_displayLabel.width,0);
			_dropdownButton.icon = Icon.EXPAND_DOWN;
			_dropdownButton.setSize(30,30);
			var buttonIcon:Icon = _dropdownButton.getIcon();
			buttonIcon.setColor('#' + Style.TEXT.value.toString(16))
			_dropdownButton.onClick.add(onClick);
			_dropdownList ||=new List(null,0,_displayLabel.height);
			_dropdownList.width = _displayLabel.width;
			_dropdownList.addClickDelegate(onListItemClick);
			super.addChildren();
		}

	private function onListItemClick(event:MouseEvent):void {
		_selectedItem = event.currentTarget as ListItem;
		trace(_selectedItem.label);
		draw();
	}

	private function onClick(event:MouseEvent):void {
		if (!_dropdownList.parent) {
			addChild(_dropdownList);
			return;
		}
		_dropdownList.visible = !_dropdownList.visible;
	}
		
		/**
		 * base method for (re)drawing the component itself. created to be overridden.
		 */
		override public function draw(e:Event = null):void {
			drawBorder();
			if (_dropdownList.numItems == 1) {

				_selectedItem = _dropdownList.getItemAt(0);
			}

			if (_selectedItem) _displayLabel.text = _selectedItem.label;
			super.draw(e);
		}

		private function drawBorder():void {
			var g:Graphics = this.graphics;
			g.lineStyle(2, Style.SECONDARY.value);
			g.drawRoundRect(0,0,_width_,_height_,7,7);
			g.endFill();
		}
		/** END INTERFACE ===================== */
		public function addListItem(item:ListItem):void {
			_dropdownList.addItem(item);
		}
		//public 
		
		// private
		// getters/setters
		// delegate functions
	}

}