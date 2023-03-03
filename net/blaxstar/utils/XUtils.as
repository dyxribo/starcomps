package net.blaxstar.utils {
import avmplus.getQualifiedClassName;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Loader;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.events.TimerEvent;
import flash.geom.Matrix;
import flash.net.FileReference;
import flash.system.Security;
import flash.utils.ByteArray;
import flash.utils.Timer;
import flash.utils.getDefinitionByName;

/**
 * ...
 * @author Deron D. (decamp.deron@gmail.com)
 */
public class XUtils {

    static public var fileRef:FileReference;
    static public var fileOperationCancelled:Boolean = false;
    static public var fileSaveSuccess:Boolean = false;
    static public var fileLoadSuccess:Boolean = false;
    static public var fileSessionComplete:Boolean = false;
    static private var timers:Vector.<Timer> = new Vector.<Timer>();
    static private var functions:Vector.<Function> = new Vector.<Function>();
    static private var parameters:Vector.<Array> = new Vector.<Array>();

    static public function getObjectClass(obj:*):Class {
        return getDefinitionByName(getQualifiedClassName(obj)) as Class;
    }

    static public function getObjectClassName(obj:*):String {
        return getQualifiedClassName(obj);
    }

    static public function deepCopy(source:Object):* {
        var bytes:ByteArray = new ByteArray();
        bytes.position = 0;
        bytes.writeObject(source);
        bytes.position = 0;
        return bytes.readObject();
    }

    static public function timedFunction(delay:Number, func:Function, params:Array):void {
        if (func == null) {
            return;
        }
        if (delay <= 0) {
            func.apply(null, params);
            return;
        }

        timers.push(new Timer(delay, 1));
        timers[timers.length - 1].addEventListener(TimerEvent.TIMER, onTimer);
        functions.push(func);
        parameters.push(params);
        timers[timers.length - 1].start();
    }

    static public function loadPolicyFile(host:String, port:uint):void {
        if (port > 65535) {
            return;
        }

        try {
            Security.allowDomain(host);
            Security.allowInsecureDomain(host);
        } catch (e:Error) {

        }

        if (host.search("://") > -1) {
            Security.loadPolicyFile(host + ":" + port);
            Security.loadPolicyFile(host + ":" + port + "/crossdomain.xml");
        } else {
            Security.loadPolicyFile("xmlsocket://" + host + ":" + port);
            Security.loadPolicyFile("https://" + host + ":" + port);
            Security.loadPolicyFile("http://" + host + ":" + port);

            Security.loadPolicyFile("xmlsocket://" + host + ":" + port + "/crossdomain.xml");
            Security.loadPolicyFile("https://" + host + ":" + port + "/crossdomain.xml");
            Security.loadPolicyFile("http://" + host + ":" + port + "/crossdomain.xml");
        }
    }

    static public function getFileNameFromURL(url:String):String {
        var fileNameIndex:int = url.lastIndexOf("/");
        if (fileNameIndex == url.length - 1) url = url.substr(0, (url.length - 1));
        fileNameIndex = url.lastIndexOf("/");
        if (fileNameIndex == url.length - 1) return url;
        return url.substr(fileNameIndex + 1);
    }

    static public function toByteArray(objs:Array):ByteArray {
        if (!objs) {
            return null;
        }

        var temp:ByteArray = new ByteArray();

        for each (var obj:* in objs) {
            var currentClassName:String = getQualifiedClassName(obj);
            if (currentClassName == "String") {
                temp.writeUTF(obj as String);
            } else if (currentClassName == "Array") {
                temp.writeObject(obj);
            } else if (getQualifiedClassName(obj) == "Boolean") {
                temp.writeBoolean(obj as Boolean);
            } else if (currentClassName == "Number") {
                temp.writeDouble(obj as Number);
            } else if (currentClassName == "int") {
                temp.writeInt(obj as int);
            } else if (currentClassName == "uint") {
                temp.writeUnsignedInt(obj as uint);
            } else {
                temp.writeObject(temp as Object);
            }
        }

        temp.position = 0;
        return temp;
    }

    static public function fromByteArray(bytes:ByteArray, classes:Array):Array {
        if (!bytes || !classes || bytes.length == 0 || classes.length == 0) {
            return null;
        }

        var retArr:Array = new Array();

        bytes.position = 0;

        for each (var cl:* in classes) {
            if (!(cl is Class)) {
                return null;
            }

            try {
                if (getQualifiedClassName(cl) == "String") {
                    retArr.push(bytes.readUTF());
                } else if (getQualifiedClassName(cl) == "Array") {
                    retArr.push(fromByteArray(bytes, classes));
                } else if (getQualifiedClassName(cl) == "Boolean") {
                    retArr.push(bytes.readBoolean());
                } else if (getQualifiedClassName(cl) == "Number") {
                    retArr.push(bytes.readDouble());
                } else if (getQualifiedClassName(cl) == "int") {
                    retArr.push(bytes.readInt());
                } else if (getQualifiedClassName(cl) == "uint") {
                    retArr.push(bytes.readUnsignedInt());
                } else {
                    retArr.push(bytes.readObject() as cl);
                }
            } catch (e:Error) {
                return null;
            }
        }

        return retArr;
    }

    static private function onTimer(e:TimerEvent):void {
        for (var i:uint = 0; i < timers.length; i++) {
            if (timers[i] === e.target) {
                timers[i].removeEventListener(TimerEvent.TIMER, onTimer);
                functions[i].apply(null, parameters[i]);
                timers.splice(i, 1);
                functions.splice(i, 1);
                parameters.splice(i, 1);
                return;
            }
        }
    }

    /**
     * saves a ByteArray into a file (opens a dialogue box).
     * @param    filedata Data to save.
     * @param    filename Name of the file.
     */
    static public function saveFile(filedata:ByteArray, filename:String):void {
        fileSessionComplete = false;
        fileSaveSuccess = false;
        fileOperationCancelled = false;

        fileRef = new FileReference();
        addSaveEvents();
        fileRef.save(filedata, filename);
        fileRef.removeEventListener(Event.SELECT, onSaveSelected);
    }

    static public function objectToArray(obj:Object):Array {
        if (!obj)
            return null;

        var finalArray:Array = [];

        for (var o:Object in obj) {
            finalArray.push(o);
        }
        return finalArray;
    }

    static public function numProperties(obj:Object):uint {
        var i:uint = 0;

        for (var o:Object in obj) {
            i++;
        }

        return i;
    }

    static public function hasProperties(obj:Object):Boolean {
        for (var o:Object in obj) {
            return true;
        }
        return false;
    }

    static public function isUniformObject(obj:Object, type:Class):Boolean {
        for (var o:* in obj) {
            if (!obj is type) {
                return false;
            }
        }
        return true;
    }

    static public function mergeObjects(...rest):Object {
        var finalObject:Object = {};

        for (var i:int = 0; i < rest.length; i++) {
            if (!getQualifiedClassName(rest[i]) == "Object")
                continue;
            if (rest[i] == {})
                continue;

            for (var o:Object in rest[i]) {
                finalObject[o] = rest[i][o];
            }
        }
        return finalObject;
    }

    static public function mergeArrays(overwrite:Boolean, ...rest):Array {
        var arr:Array = [];

        for (var i:int = 0; i < rest.length; i++) {
            for (var j:int = 0; j < rest[i].length; j++) {
                if (!overwrite || !(arr.indexOf(rest[i][j]) > -1)) arr.push(rest[i][j]);
            }
        }
        return arr;
    }

    static public function arrayToObject(arr:Array, propNames:Array = null):Object {
        var outputObj:Object = {};
        for (var i:uint = 0; i < arr.length; i++) {
            if (propNames)
                outputObj[propNames[i]] = arr[i];
            else
                outputObj["obj_" + i] = arr[i];
        }

        return outputObj;
    }

    static public function arrayToString(array:Array):String {
        var finalString:String = "{&quot}";
        var i:uint = 0;

        for (var o:Object in array) {
            ++i;
            if (o is Array)
                finalString = finalString + arrayToString(array[o] as Array) + "{&quot}";
            else if (getQualifiedClassName(array[o]) == "Object")
                finalString = finalString + JSON.stringify(array[o]) + "{&quot}";
            else
                (i == array.length) ? finalString = finalString + array[o] + "{&quot}" : finalString = finalString + array[o] + "|";
        }

        return finalString.replace("{&quot}", "\"");
    }

    static public function alphaNumericSort(a:String, b:String):int {
        a = a.toLowerCase();
        b = b.toLowerCase();
        var reA:RegExp = /[^a-zA-Z]/g;
        var reN:RegExp = /[^0-9]/g;
        var aA:String = a.replace(reA, "");
        var bA:String = b.replace(reA, "");
        if (aA === bA) {
            var aN:Number = parseInt(a.replace(reN, ""), 10);
            var bN:Number = parseInt(b.replace(reN, ""), 10);
            return aN === bN ? 0 : aN > bN ? 1 : -1;
        } else
            return aA > bA ? 1 : -1;
    }

    static public function setRegistrationPoint(s:Sprite, regx:Number, regy:Number, showRegistration:Boolean):void {
        s.transform.matrix = new Matrix(1, 0, 0, 1, -regx, -regy);

        // draw registration point.
        if (showRegistration) {
            var mark:Sprite = new Sprite();
            mark.graphics.lineStyle(1, 0x000000);
            mark.graphics.moveTo(-5, -5);
            mark.graphics.lineTo(5, 5);
            mark.graphics.moveTo(-5, 5);
            mark.graphics.lineTo(5, -5);
            s.parent.addChild(mark);
        }
    }

    static public function removeAndNullChildren(dOC:DisplayObjectContainer, nullSelf:Boolean = true):void {
        if (!dOC) return;
        for (var i:uint = 0; i < dOC.numChildren; ++i) {
            //check if child is a DisplayObjectContainer, which could hold more children
            if (dOC.getChildAt(i) is DisplayObjectContainer) removeAndNullChildren(DisplayObjectContainer(dOC.getChildAt(i)));
            else {
                //remove and null child of parent
                var child:DisplayObject = dOC.getChildAt(i);
                if (!(dOC is Loader)) dOC.removeChild(child);
                child = null;
            }
        }
        //remove and null parent
        if (!(dOC is Stage)) {
            if (dOC.parent) dOC.parent.removeChild(dOC);
            if (nullSelf) dOC = null;
        }
    }

    static public function getNumChildren(dOC:DisplayObjectContainer):uint {
        if (!dOC) return 0;
        var numCh:uint = 0;

        for (var i:uint = 0; i < dOC.numChildren; ++i) {
            //check if child is a DisplayObjectContainer, which could hold more children
            if (dOC.getChildAt(i) is DisplayObjectContainer) numCh += getNumChildren(DisplayObjectContainer(dOC.getChildAt(i)));
            else {
                ++numCh;
            }
        }

        return numCh;
    }

    static public function htmlToString(text:String):String {
        var removeHtmlRegExp:RegExp = new RegExp("<[^<]+?>", "gi");
        text = text.replace(removeHtmlRegExp, "");
        text = text.replace("&amp;", "&");
        return text;
    }

    // DELEGATES =======================================================================================================

    static private function addSaveEvents():void {
        fileRef.addEventListener(Event.SELECT, onSaveSelected);
        fileRef.addEventListener(IOErrorEvent.IO_ERROR, onSaveIOError);
        fileRef.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSaveSecurityError);
        fileRef.addEventListener(ProgressEvent.PROGRESS, onSaveProgress);
        fileRef.addEventListener(Event.COMPLETE, onSaveComplete);
    }

    static private function killSaveEvents():void {
        fileRef.removeEventListener(Event.CANCEL, onSaveCancel);
        fileRef.removeEventListener(IOErrorEvent.IO_ERROR, onSaveIOError);
        fileRef.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSaveSecurityError);
        fileRef.removeEventListener(ProgressEvent.PROGRESS, onSaveProgress);
        fileRef.removeEventListener(Event.COMPLETE, onSaveComplete);
    }

    static private function onSaveSelected(e:Event):void {
        fileRef.addEventListener(ProgressEvent.PROGRESS, onSaveProgress);
        fileRef.addEventListener(Event.COMPLETE, onSaveComplete);
        fileRef.addEventListener(Event.CANCEL, onSaveCancel);
    }

    static private function onSaveIOError(e:IOErrorEvent):void {
        trace("There was an IO error.");
        fileOperationCancelled = true;
        fileSessionComplete = true;

        killSaveEvents();
    }

    static private function onSaveSecurityError(e:SecurityErrorEvent):void {
        trace("There was a security error.");
        fileOperationCancelled = true;
        fileSessionComplete = true;

        killSaveEvents();
    }

    static private function onSaveProgress(e:ProgressEvent):void {
        trace("Saved " + e.bytesLoaded + " bytes of " + e.bytesTotal + " total.");
    }

    static private function onSaveComplete(e:Event):void {
        trace("File saved!");
        fileSaveSuccess = true;
        fileSessionComplete = true;

        killSaveEvents();
    }

    static private function onSaveCancel(e:Event):void {
        trace("The save request was terminated by the user.");
        fileOperationCancelled = true;
        fileSessionComplete = true;
        fileSaveSuccess = false;

        killSaveEvents();
    }
}
}