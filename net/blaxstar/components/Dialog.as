package net.blaxstar.components {
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Deron Decamp
	 */
	public class Dialog extends Component {
		
		protected var _titlePT:PlainText;
		protected var _messagePT:PlainText;
		private var _titleString:String;
		private var _messageString:String;
		private var _textContainer:VerticalBox;
		private var _dialogCard:Card;
		private var _scrollbar:ScrollbarControl;
		
		public function Dialog(parent:DisplayObjectContainer=null, title:String='TITLE', message:String='THIS IS A MESSAGE. DO YOU AGREE?') {
			_titleString = title;
			_messageString = message;
			super(parent);
		}
		
		/** INTERFACE net.blaxstar.components.IComponent ===================== */ 
		
		/**
		 * initializes the component by adding all the children 
		 * and committing the visual changes to be written on the next frame.
		 * created to be overridden.
		 */
		override public function init():void {
			super.init();
		}
		/**
		 * initializes and adds all required children of the component.
		 */
		override public function addChildren():void {
			
			_dialogCard = new Card(this, 0, 0, false);
			_textContainer = new VerticalBox(_dialogCard, PADDING, PADDING);
			_titlePT = new PlainText(_textContainer, 0, 0, _titleString);
			_titlePT.enabled = false;
			_messagePT = new PlainText(_textContainer, 0, 0, _messageString);
			_dialogCard.onResize.add(draw);
			_dialogCard.addOption('NO',null, Card.OPTION_EMPHASIS_HIGH);
			_dialogCard.addOption('YES');
			_dialogCard.draggable = false;
		}
		/**
		 * (re)draws the component and applies any pending visual changes.
		 */
		override public function draw(e:Event = null):void {
			_width_ = _dialogCard.width;
			_height_ = _dialogCard.height;
			//scrollRect ||= new Rectangle(x,y,_width_,_height_);
			//scrollRect.width = _width_;
			//scrollRect.height = _height_;
			componentContainer.move(PADDING, _textContainer.y + _textContainer.height + PADDING);
			optionContainer.move(PADDING, _height_);
			move((stage.nativeWindow.width / 2) - (_width_ / 2), (stage.nativeWindow.height / 2) - (_width_ / 2));
			super.draw(e);
		}
		/** END INTERFACE ===================== */ 
		
		public function addComponent(val:DisplayObject) : DisplayObject {
			return _dialogCard.addChildToContainer(val);
		}

		public function set viewableItems(val:uint):void {
			_dialogCard.viewableItems = val;
		}

		public function set maskThreshold(val:Number):void {
			_dialogCard.maskThreshold = val;
		}

		public function addOption(name:String, action:Function=null, emphasis:uint=Card.OPTION_EMPHASIS_LOW):Button {
			var b:Button = new Button(_dialogCard.optionContainer, 0, 0, name);
			if (action != null) b.addClickListener(action);
			if (emphasis == Card.OPTION_EMPHASIS_LOW) {
				b.style = Button.DEPRESSED;
			} else if (emphasis == Card.OPTION_EMPHASIS_HIGH) {
				b.style = Button.GROUNDED;
			}
			
			commit();
			return  b;
		}
		
		public function get componentContainer():VerticalBox {
			return _dialogCard.componentContainer;
		}
		
		public function get optionContainer():HorizontalBox {
			return _dialogCard.optionContainer;
		}
		
	}

}