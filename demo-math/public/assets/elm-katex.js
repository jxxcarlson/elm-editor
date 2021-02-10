const init =  async function(app) {

    console.log("I am starting elm-katex: init");
    var katexJs = document.createElement('script')
    katexJs.type = 'text/javascript'
    katexJs.onload = initKatex
    katexJs.src = "https://cdn.jsdelivr.net/npm/katex@0.12.0/dist/katex.min.js"
  
    document.head.appendChild(katexJs);
    console.log("elm-katex: I have appended katexJs to document.head");
  
  }
  
  function initKatex() {
  
    console.log("elm-katex: initializing");
  
    class MathText extends HTMLElement {
  
       constructor() {
           // Always call super first in constructor
           super();
         }
  
      connectedCallback() {
        this.attachShadow({mode: "open"});
        this.shadowRoot.innerHTML =
          katex.renderToString(
            this.content,
            { throwOnError: false, displayMode: this.display }
          );
        let link = document.createElement('link');
        link.setAttribute('rel', 'stylesheet');
        link.setAttribute('href', 'https://cdn.jsdelivr.net/npm/katex@0.12.0/dist/katex.min.css');
        this.shadowRoot.appendChild(link);
  
      }
  
    }
  
    customElements.define('math-text', MathText)
  
  }
  