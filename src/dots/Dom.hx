package dots;

import js.html.Document;
import js.html.HTMLDocument;
import js.html.Element;
import js.html.Window;
import js.Browser.*;
import haxe.ds.Either;

class Dom {
  public static function addCss(css : String, ?container : Element) {
    if(null == container)
      container = document.head;
    var style = document.createStyleElement();
    style.type = "text/css";
    style.appendChild(document.createTextNode(css));
    container.appendChild(style);
  }

  public static function getValue(el : Element) : Null<String>
    return switch el.nodeName {
      case "INPUT":
        var input : js.html.InputElement = cast el;
        if (input.type == "checkbox" && !input.checked) null;
        else input.value;
      case "TEXTAREA":
        var textarea : js.html.TextAreaElement = cast el;
        textarea.value;
      case "SELECT":
        var select : js.html.SelectElement = cast el,
        option : js.html.OptionElement = cast select.options.item(select.selectedIndex);
        option.value;
      case _:
        el.innerHTML;
      };

  public static function getMultiValue(el : Element) : Either<String, Array<String>>
    return switch el.nodeName {
      case "INPUT":
        var input : js.html.InputElement = cast el;
        if (input.type == "checkbox" && !input.checked) Right([]);
        else Left(input.value);
      case "TEXTAREA":
        var textarea : js.html.TextAreaElement = cast el;
        Left(textarea.value);
      case "SELECT":
        var select : js.html.SelectElement = cast el;
        if (select.multiple) {
          var values = [];
          var options = select.selectedOptions;
          for(i in 0...options.length)
            values.push((cast options[i] : js.html.OptionElement).value);

          Right(values);
        }
        else {
          var option : js.html.OptionElement = cast select.options.item(select.selectedIndex);
          Left(option.value);
        }

      case _:
        Left(el.innerHTML);
    };

  public static function getWindowHeight(?win : Window) : Int {
    if(null == win) win = window;
    return win.document.documentElement.clientHeight;
  }

  public static function getWindowWidth(?win : Window) : Int {
    if(null == win) win = window;
    return win.document.documentElement.clientWidth;
  }

  public static function getWindowSize(?win : Window) : { width : Int, height : Int } {
    if(null == win) win = window;
    return { width : win.document.documentElement.clientWidth, height : win.document.documentElement.clientHeight };
  }

  public static function getWindowInnerHeight(?win : Window) : Int {
    if(null == win) win = window;
    return win.innerHeight;
  }

  public static function getWindowInnerWidth(?win : Window) : Int {
    if(null == win) win = window;
    return win.innerWidth;
  }

  public static function getWindowInnerSize(?win : Window) : { width : Int, height : Int } {
    if(null == win) win = window;
    return { width : win.innerWidth, height : win.innerHeight };
  }

  public static function getDocumentHeight(?doc : Document) : Int {
    if(null == doc) doc = document;
    return doc.documentElement.scrollHeight;
  }

  public static function getDocumentWidth(?doc : Document) : Int {
    if(null == doc) doc = document;
    return doc.documentElement.scrollWidth;
  }

  public static function getDocumentSize(?doc : Document) : { width : Int, height : Int } {
    if(null == doc) doc = document;
    return { width : doc.documentElement.scrollWidth, height : doc.documentElement.scrollHeight };
  }

  public static function getScrollTop(?doc : HTMLDocument) {
    if(null == doc) doc = document;
    if(null != doc.documentElement)
      return doc.documentElement.scrollTop;
    else
      return doc.body.scrollTop;
  }

  public static function getOffset(el : Element, ?doc : HTMLDocument) {
    if(null == doc) doc = document;
    var rect = el.getBoundingClientRect();
    return {
      top: Math.round(rect.top + doc.body.scrollTop),
      left: Math.round(rect.left + doc.body.scrollLeft)
    };
  }

  public static function getOffsetParent(el : Element)
    return null != el.offsetParent ? el.offsetParent : el;

  inline public static function getOuterHeight(el : Element)
    return el.offsetHeight;

  public static function getOuterHeightWithMargin(el : Element) {
    var h = el.offsetHeight,
        s = Style.style(el);
    return h + Std.parseInt(s.marginTop) + Std.parseInt(s.marginBottom);
  }

  inline public static function getOuterWidth(el : Element)
    return el.offsetWidth;

  public static function getOuterWidthWithMargin(el : Element) {
    var h = el.offsetWidth,
        s = Style.style(el);
    return h + Std.parseInt(s.marginLeft) + Std.parseInt(s.marginRight);
  }

  inline public static function getPosition(el : Element)
    return { left: el.offsetLeft, top: el.offsetTop };

  public static function ready(fn : Void -> Void, doc : Document) {
    if(null == doc) doc = document;
    if (doc.readyState != 'loading'){
      fn();
    } else {
      doc.addEventListener('DOMContentLoaded', fn);
    }
  }

  inline public static function empty(el : Element)
    el.innerHTML = "";

  static function __init__() {
#if polyfill
    haxe.macro.Compiler.includeFile("src/dots/classList.js");
    haxe.macro.Compiler.includeFile("src/dots/eventListener.js");
#end
  }
}
