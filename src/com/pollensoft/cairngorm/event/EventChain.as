package com.pollensoft.cairngorm.event
{
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.pollensoft.util.ApplicationProgress;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	import mx.collections.ArrayCollection;
	import mx.rpc.IResponder;

	[Event(name="cancel", type="flash.events.Event")]
	[Event(name="complete", type="flash.events.Event")]
	[Event(name="progress", type="com.pollensoft.cairngorm.event.ChainEvent")]
	[Event(name="progressComplete", type="com.pollensoft.cairngorm.event.ChainEvent")]

	/**
	 * Contains a sequence of potentially arbitrary, sequenced events to
	 * execute in a particular order.  Each event can be marked as required,
	 * which can help determine which landmarks this process must complete in
	 * order to continue processing.
	 *
	 * <p>
	 * ChainEvents and their subsequent ChainCommands can relay results and faults
	 * to a responder, which can ask the EventChain to continue or stop dispatching
	 * events.
	 * </p>
	 *
	 * @author jason.proulx
	 */
	public class EventChain implements IResponder, IEventDispatcher
	{
		public static const COMPLETE:String = Event.COMPLETE;
		public static const CANCEL:String = Event.CANCEL;

		private var responder:IResponder;
		private var events:ArrayCollection;
		private var cursor:int = -1;
		private var dispatcher:EventDispatcher;
		private var _cancelled:Boolean = false;

		private var executeAll:Boolean;

		/**
		 *
		 * @param responder
		 * @return
		 *
		 */
		public function EventChain( responder:IResponder=null )
		{
			this.events = new ArrayCollection();
			this.dispatcher = new EventDispatcher(this);
			this.responder = responder;

			addEventListener(COMPLETE, onComplete);

			ApplicationProgress.registerChain(this);

			reset();
		}

		private function onComplete(event:Event):void
		{
			ApplicationProgress.unregisterChain(this);
		}

		public function start(executeAll:Boolean = false):void
		{
			next(executeAll);
		}

		/**
		 *
		 * @return the number of events in this Chain
		 *
		 */
		public function get length():Number
		{
			return events.length;
		}

		public function get cancelled():Boolean
		{
			return _cancelled;
		}

		public function cancel():void
		{
			_cancelled = true;

			dispatchEvent(new Event(CANCEL));
		}

		/**
		 * Add an event to the collection of Events to dispatch.
		 *
		 * @param event
		 * @param required landmark event?
		 *
		 */
		public function addEvent(event:ChainEvent, required:Boolean=false):void
		{
			event.required = required;
			event.chain = this;

			events.addItem(event);
		}

		/**
		 * Relay a result to the responder and automatically continue.
		 *
		 * @param data
		 *
		 */
		public function result(data:Object):void
		{
			if(responder) responder.result(data);

			var p:ChainEvent = new ChainEvent(ChainEvent.PROGRESS_COMPLETE);
				p.origin = currentEvent;

			dispatchEvent(p);

			next(executeAll);
		}

		/**
		 * Relay a fault to the responder.  If the responder determines the fault isn't important, the responder will
		 * need to explicitly tell the chain to continue.
		 *
		 * @param info
		 *
		 */
		public function fault(info:Object):void
		{
			var p:ChainEvent = new ChainEvent(ChainEvent.PROGRESS_FAILED);
				p.origin = currentEvent;

			dispatchEvent(p);

			if(responder) responder.fault(info);
		}

		/**
		 * Return the currently executing event in this series.
		 *
		 * @return
		 *
		 */
		public function get currentEvent():ChainEvent
		{
			var ev:ChainEvent;
			try {
				ev = events.getItemAt(this.cursor) as ChainEvent;
			} catch(e:Error) {
				ev = null;
			}
			return ev;
		}

		/**
		 * Dispatch the next event, if executeAll is true, dispatch all of the
		 * next events until a required event is encountered.  May speed load times
		 * if multiple events can be executed in parallel.
		 *
		 * @param executeAll Execute all events up to the next required event?
		 *
		 */
		public function next(executeAll:Boolean=false):void
		{
			this.executeAll = executeAll;

			if(executeAll) {
				while(currentEvent != null && !currentEvent.required) {
					doNext();
				}
			} else {
				doNext();
			}
		}

		/**
		 * Dispatch the next event in the series.  If there are no events left to execute,
		 * it dispatches a local COMPLETE event.
		 *
		 */
		private function doNext():void
		{
			cursor++;

			if(cursor >= length || currentEvent == null || cancelled)
			{
				dispatcher.dispatchEvent(new Event(Event.COMPLETE));
			}
			else
			{
				var p:ChainEvent = new ChainEvent(ChainEvent.PROGRESS);
					p.origin = currentEvent;

				dispatchEvent(p);

				CairngormEventDispatcher.getInstance().dispatchEvent(currentEvent);
			}
		}

		/**
		 * Reset the cursor, good for re-running the sequence of events, possibly after the
		 * resolution of a fault.
		 */
		public function reset():void
		{
			cursor = -1;
		}

		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			dispatcher.addEventListener(type, listener, useCapture, priority);
		}

		public function dispatchEvent(evt:Event):Boolean
		{
			return dispatcher.dispatchEvent(evt);
		}

		public function hasEventListener(type:String):Boolean
		{
			return dispatcher.hasEventListener(type);
		}

		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			dispatcher.removeEventListener(type, listener, useCapture);
		}

		public function willTrigger(type:String):Boolean
		{
			return dispatcher.willTrigger(type);
		}
	}
}