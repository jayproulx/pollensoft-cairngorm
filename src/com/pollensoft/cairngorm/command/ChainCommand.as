package com.pollensoft.cairngorm.command
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.pollensoft.cairngorm.event.ChainEvent;
	
	import mx.rpc.IResponder;
	
	/**
	 * A ChainCommand is a Command that responds to its event when it
	 * finishes processing.  With the use of an EventChain and ChainEvents,
	 * you can string together arbitrary sequences of ChainCommands.
	 * 
	 * @author jason.proulx
	 * @see com.pollensoft.cairngorm.util.event.EventChain
	 * @see com.pollensoft.cairngorm.util.event.ChainEvent
	 */
	public class ChainCommand implements ICommand
	{
		/**
		 * The CairngormEvent that initiated this Command.
		 */		
		protected var event:CairngormEvent;
		
		/**
		 * This execute method should be called before any processing is done
		 * in the subclass of this ChainCommand via super.execute(event).
		 * 
		 * <P>This will register the event with this class, and allow for prcessing
		 * result() and fault() when processing completes.
		 * 
		 * @param event
		 * @see #fault()
		 * @see #result()
		 */
		public function execute(event:CairngormEvent):void
		{
			this.event = event;
		}
		
		/**
		 * This method must be called <u>after</u> your Command finishes executing
		 * successfully.  This will notify the EventChain that this command has
		 * completed and to continue on to the next event.
		 * 
		 * @param data
		 */		
		public function complete(data:Object):void
		{
			if(event is ChainEvent) {
				var e:ChainEvent = event as ChainEvent;
				
				e.result(data);
			}
		}
		
		/**
		 * This method must be called <u>after</u> your Command has failed, and done
		 * any cleanup.  This will notify the EventChain that this command has failed
		 * and to determine whether or not to continue.
		 * 
		 * @param info
		 */
		public function fail(info:Object):void
		{
			if(event is ChainEvent) {
				var e:ChainEvent = event as ChainEvent;
				
				e.fault(info);
			}
		}
		
	}
}