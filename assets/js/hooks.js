let Hooks = {}

// Hooks.ContentToLocalTime = {
//   mounted() {
//     this.updated();
//   },
//   updated() {
//     const el = this.el;
//     const date = new Date(el.dateTime);
//     this.el.textContent = `${date.toLocaleString()}`;
//   },
// };

// Hooks.SetValueToLocalTimeNow = {
//   mounted() {
//     this.updated();
//   },
//   updated() {
//     const el = this.el;
//     console.log("el.value", el.value);
//     var date = (el.value ? new Date(el.value) : new Date())
//     console.log("new or parsed", date)
//     var adjusted_date = new Date(date.setMinutes(date.getMinutes() - date.getTimezoneOffset())
//     );
//     console.log("offset adjusted", adjusted_date);
//     console.log("adjusted sliced", adjusted_date.toISOString().slice(0, 16));
//     this.el.value = adjusted_date.tol().slice(0, 16);
//     console.log("this.el.value", this.el.value);
//   },
// };

export default Hooks