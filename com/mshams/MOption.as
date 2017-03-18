/***********************************************************
 * Class name: MOption
 * Version:    1.0
 *
 * Author:     Mohammad Shams Javi
 * Website:    http://www.mshams.ir
 * Weblog:     http://blog.mshams.ir
 * Contact:    info@mshams.ir
 *
 * Description:
 *    This is a simple class to read and write setting files in local filesystem. 
 * 	  Setting file can be stored in application's directory and there is no limitation 
 * 	   to Flash/AIR application sandbox directories.
 * 
 *
 ***********************************************************
 ****************** BEGIN LICENSE BLOCK ********************
 *                 
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is MOption Class
 *
 * The Initial Developer of the Original Code is
 * Mohammad Shams Javi
 *
 * Portions created by the Initial Developer are Copyright (C) 2010
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *
 ****************** END LICENSE BLOCK **********************
 Updates
 ***********************************************************
 * Date:       
 * Author:     
 * Version:    
 * Update:     
 ***********************************************************/

package com.mshams
{
	import flash.net.URLRequest;	
	import flash.events.*;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;	
	import flash.filesystem.FileStream;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;

	public class MOption extends EventDispatcher
	{
		//Evetnts
		public static var LOAD_COMPLETE:String = "loadComplete";
		public static var SAVE_COMPLETE:String = "saveComplete";
		public static var LOAD_ERROR:String = "loadError";
		public static var SAVE_ERROR:String = "saveError";
		public static var PARSE_ERROR:String = "parseError";
		public static var OPTION_RETRIVE_ERROR:String = "optionRetriveError";

		//Private variables
		private var _file:FileStream;
		private var _lod:URLLoader;
		private var _path:String;
		private var _xml:XML;
		private var _xmlHeaderStr:String = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
		private var _emptyXml:XML = <MOption_Root>	</MOption_Root>;
		private var _tempFile:File;


		public function MOption(filePath:String)
		{
			// constructor
			_path = filePath;			
			_lod = new URLLoader();
			_lod.dataFormat = URLLoaderDataFormat.BINARY;
		}


		public function setOption(optName:String, optValue:Object)
		{
			if (optName != "" && optValue != "")
			{
				if (_xml.child(optName).length() > 0)
				{
					_xml.replace(optName, formatOption(optName, optValue));
				}
				else
				{
					_xml.appendChild(formatOption(optName, optValue));
				}
			}
		}


		public function getOption(optName:String):Object
		{
			if (_xml != null && optName != "")
			{
				try
				{
					return _xml.child(optName).toString();
				}
				catch (e:ErrorEvent)
				{
					dispatchEvent(new Event(MOption.OPTION_RETRIVE_ERROR));
					return null;
				}
			}
			return null;
		}


		public function getArrayOption():Array
		{
			//return all option values and theire names as a 2d array
			var _out:Array = new Array();
			for each (var tempXML:XML in _xml.children())
			{
				_out.push([tempXML.name(), tempXML]);
			}

			return _out;
		}


		public function loadData():void
		{	
			//locate the path variable to local filesystem and application directory
			//you can also use a sub directory as input path  ex: "files/setting.xml"
			_tempFile = new File("file:///" + File.applicationDirectory.nativePath + "/" + _path);

			//If file exist, load it! otherwise create a temp xml.
			if (_tempFile.exists)
			{
				_lod.addEventListener(IOErrorEvent.IO_ERROR, evtLoadError);
				_lod.addEventListener(flash.events.Event.COMPLETE,evtLoadComplete);
				_lod.load(new URLRequest(_path));
			}
			else
			{
				_xml = new XML(_emptyXml);
				dispatchEvent(new Event(MOption.LOAD_COMPLETE));							
			}
		}


		public function saveData()
		{
			//new File("app:/" + );
			_file = new FileStream  ;			

			try
			{
				_file.addEventListener(IOErrorEvent.IO_ERROR, evtSaveError);
				_file.addEventListener(Event.CLOSE, evtSaveComplete);

				_file.openAsync(_tempFile, FileMode.WRITE);
				//write xml header and body
				_file.writeUTFBytes(_xmlHeaderStr);
				_file.writeUTFBytes(_xml.toString());
			}
			catch (e:SecurityError)
			{
				//trace(e.errorID, e.message);
				dispatchEvent(new Event(MOption.SAVE_ERROR));
			}
			finally
			{
				_file.close();
			}
		}


		private function formatOption(optName:String, optValue:Object):XML
		{
			//xml.appendChild(<p>world</p>);
			return XML("<" + optName + ">" + optValue.toString() + "</" + optName + ">");
		}


		private function evtLoadComplete(e:Event)
		{
			try
			{
				_xml = new XML(e.target.data);
				//trace("xml=", _xml);
				dispatchEvent(new Event(MOption.LOAD_COMPLETE));
			}
			catch (e:TypeError)
			{
				dispatchEvent(new Event(MOption.PARSE_ERROR));
			}
		}
		

		private function evtLoadError(e:IOErrorEvent)
		{
			//trace("Error in loader", e.text, e.errorID,e);
			dispatchEvent(new Event(MOption.LOAD_ERROR));
		}


		private function evtSaveError(e:IOErrorEvent)
		{
			dispatchEvent(new Event(MOption.SAVE_ERROR));
		}


		private function evtSaveComplete(e:Event)
		{
			dispatchEvent(new Event(MOption.SAVE_COMPLETE));
		}

	}
}