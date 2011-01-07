package com.pollensoft.cairngorm.event
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import mx.rpc.IResponder;
	import flash.events.Event;
	
	/**
	 * One single event in an EventChain.  This Event type can store
	 * a required flag, as well as communicate faults and results between
	 * a ChainCommand and the EventChain.
	 * 
	 * @author jason.proulx
	 * 
	 */
	public class ChainEvent extends CairngormEvent implements IResponder
	{
		public static const PROGRESS:String = "progress";
		public static const PROGRESS_COMPLETE:String = "progressComplete";
		public static const PROGRESS_FAILED:String = "progressFailed";

		public var required:Boolean;
		public var chain:EventChain;
		public var origin:ChainEvent;

		public function ChainEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		/**
		 * If a chain has been specified, relay the result to the Chain.
		 * 
		 * @param data
		 * 
		 */
		public function result(data:Object):void
		{
			if(chain) {
				chain.result(data);
			}
		}
		
		/**
		 * If a chain has been specified, relay the fault to the Chain.
		 * @param info
		 * 
		 */
		public function fault(info:Object):void
		{
			if(chain) {
				chain.fault(info);
			}
		}
		
	}
}