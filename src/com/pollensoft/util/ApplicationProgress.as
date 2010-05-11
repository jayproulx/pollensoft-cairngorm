package com.pollensoft.util
{
	import com.pollensoft.cairngorm.event.EventChain;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.controls.ProgressBar;
	import mx.core.Application;
	import mx.managers.PopUpManager;
	
	public class ApplicationProgress
	{
		private static var _numTasks:uint = 0;
		private static var _completedTasks:uint = 0;
		
		private static var dispatcher:EventDispatcher = new EventDispatcher();
		private static var chains:ArrayCollection = new ArrayCollection();
		private static var progressWindow:ApplicationProgressWindow = new ApplicationProgressWindow();
		private static var windowOpen:Boolean = false;
		
		public static function get numTasks():uint {
			return _numTasks;
		}
		
		public static function set numTasks(value:uint):void {
			_numTasks = value;
			
			if(windowOpen) {
				progressBar.setProgress(completedTasks, _numTasks);
				progressBar.indeterminate = numTasks == 0;
			}
		}
		
		public static function get completedTasks():uint {
			return _completedTasks;
		}
		
		public static function set completedTasks(value:uint):void {
			_completedTasks = value;
			
			if(windowOpen) {
				progressBar.setProgress(_completedTasks, numTasks);
				
				if(completedTasks >= numTasks) {
					dispatchEvent(new Event(Event.COMPLETE));
					reset();
				}
			}
			
		}
		
		public static function get progressBar():ProgressBar {
			return progressWindow.progressBar;
		}
		
		public static function set progressBar(value:ProgressBar):void {
		}
		
		public static function addTasks(num:uint):void {
			numTasks += num;
		}
		
		public static function complete():void {
			completedTasks++;
		}
		
		public static function reset():void {
			_numTasks = 0;
			_completedTasks = 0;
			
			if(windowOpen) {
				PopUpManager.removePopUp(progressWindow);
			}
			
			progressWindow.progressBar.indeterminate = true;
			progressWindow.progressBar.label = "LOADING";
			progressWindow.removeEventListener(Event.CANCEL, handleCancel);
			
			windowOpen = false;
		}
		
		private static function handleCancel(event:Event):void {
			for each(var chain:EventChain in chains) {
				chain.cancel();
			}
			
			reset();
		}
		
		public static function registerChain(chain:EventChain):void {
			chains.addItem(chain);
		}
		
		public static function unregisterChain(chain:EventChain):void {
			chains.removeItemAt(chains.getItemIndex(chain));
		}
		
		public static function show(message:String):void {
			progressWindow.title = "Progress";
			
			if(!windowOpen) {
				PopUpManager.addPopUp(progressWindow, Application.application as DisplayObject, true);
				
				progressWindow.addEventListener(Event.CANCEL, handleCancel);
				
				PopUpManager.centerPopUp(progressWindow);
				windowOpen = true;
			}
			
			try {
				progressBar.label = message;
				progressBar.indeterminate = numTasks == 0;
				progressBar.invalidateDisplayList();
				progressBar.invalidateProperties();
				progressWindow.invalidateDisplayList();
				progressWindow.invalidateProperties();
			} catch(e:Error) {
				
			}
		}
		
		
		public static function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void{
			// only one at a time please.
			dispatcher.removeEventListener(type, listener, useCapture);
			
			dispatcher.addEventListener(type, listener, useCapture, priority);
		}
		
		public static function dispatchEvent(evt:Event):Boolean{
			return dispatcher.dispatchEvent(evt);
		}
		
		public static function hasEventListener(type:String):Boolean{
			return dispatcher.hasEventListener(type);
		}
		
		public static function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void{
			dispatcher.removeEventListener(type, listener, useCapture);
		}
		
		public static function willTrigger(type:String):Boolean {
			return dispatcher.willTrigger(type);
		}		
	}
}