<template>
  <div id="app">
    <b-jumbotron v-bind:header="message">
      <input v-model="message">
      <b-button variant="primary" v-b-tooltip.hover title="Reverse message" v-on:click="reverseMessage">
        <b-icon icon="arrow-counterclockwise" animation="spin-reverse"></b-icon>
        Reverse Message
      </b-button>
    </b-jumbotron>  
  </div>
</template>

<script>
export default {
  data: function () {
    return {
      message: "Hi Vue!"
    }
  },
 methods: {
    reverseMessage: function () {
      this.message = this.message.split('').reverse().join('')
    }
  }
}
</script>

<style scoped>
p {
  font-size: 2em;
  text-align: center;
}
</style>
