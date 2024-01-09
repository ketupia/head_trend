let Hooks = {}

Hooks.ContentToLocalTime = {
  mounted() {
    this.updated();
  },
  updated() {
    const el = this.el;
    const date = new Date(el.dateTime);
    this.el.textContent = `${date.toLocaleString()}`;
  },
};

Hooks.SetValueToLocalTimeNow = {
  mounted() {
    this.updated();
  },
  updated() {
    const el = this.el;
    const date = new Date();
    date.setMinutes(date.getMinutes() - date.getTimezoneOffset());
    this.el.value = date.toISOString().slice(0, 16);
    // this.el.value = `${date.toLocaleString()}`;
  },
};

export default Hooks