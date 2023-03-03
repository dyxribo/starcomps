package net.blaxstar.components {
import flash.events.Event;

/**
	 * ...
	 * @author Deron Decamp
	 */
	public interface IComponent {
		
		function init():void;
		
		function addChildren():void;
		
		function draw(e:Event = null):void
	}

}