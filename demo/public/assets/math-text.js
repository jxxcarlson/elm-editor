// Old version

//class MathText extends HTMLElement {
//
//   // The paragraph below detects the
//   // argument to the custom element
//   // and is necessary for innerHTML
//   // to receive the argument.
//   set content(value) {
//  		this.innerHTML = value
//  	}
//
//  connectedCallback() {
//    this.attachShadow({mode: "open"});
//    this.shadowRoot.innerHTML =
//      '<mjx-doc><mjx-head></mjx-head><mjx-body>' + this.innerHTML + '</mjx-body></mjx-doc>';
//    MathJax.typesetShadow(this.shadowRoot);
//    // setTimeout(() => MathJax.typesetShadow(this.shadowRoot), 1);
//  }
//}


// New version

customElements.define('math-text', MathText)

class MathText extends HTMLElement {

  constructor(...args) {
    super(...args);
    this.attachShadow({mode: "open"});
    this.shadowRoot.innerHTML = '<mjx-doc><mjx-head></mjx-head><mjx-body></mjx-body></mjx-doc>';
    MathText.observer.observe(this, {childList: true});
  }

  connectedCallback() {
    MathText.observer.observe(this, {childList: true});
  }

  disconnectedCallback() {
    MathText.observer.disconnect(this, {childList: true});
  }

}

MathText.contentChanged = (list) => {
  for (const item of list) {
    const node = item.target;
    if (node.isConnected) {
      node.shadowRoot.firstChild.lastChild.innerHTML = node.innerHTML;
      setTimeout(() => MathJax.typesetShadow(node.shadowRoot), 1);
    }
  }
}

MathText.observer = new MutationObserver(MathText.contentChanged);

customElements.define('math-text', MathText);
