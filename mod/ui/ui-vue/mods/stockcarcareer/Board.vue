<script>
const modInfo = { uiSlots: ["mainmenu.top"] }
</script>
<script setup>
import { ref } from "vue"
import { useBridge } from "@/bridge"

const { api } = useBridge()

const open = ref(false)
const board = ref(null)
const message = ref("")
const busy = ref(false)

async function act(action) {
  if (busy.value) return
  busy.value = true
  message.value = ""
  try {
    const calls = {
      sign: "race.signCareerSponsor()",
      training: "race.launchCareer(true)",
      race: "race.launchCareer(false)",
    }
    const actionCall = calls[action] || "race.careerState()"
    const result = await new Promise(resolve => api.engineLua(`(function()
      extensions.load("daytonaRaceControl")
      local race = extensions.daytonaRaceControl
      return ${actionCall}
    end)()`, resolve))
    if (action === "training" || action === "race") {
      message.value = typeof result === "string" ? result : "The event could not be started."
      if (!message.value) open.value = false
      return
    }
    if (!result || !result.rounds) throw new Error("Career state unavailable")
    board.value = result
  } catch {
    message.value = "Career data could not be loaded."
  } finally {
    busy.value = false
  }
}

function show() {
  open.value = true
  act()
}
</script>

<template>
  <button class="career-entry" @click="show">Stock Car Career</button>
  <Teleport to="body">
    <div v-if="open" class="career-backdrop" @keydown.esc.stop="open = false">
      <section class="career-board" role="dialog" aria-modal="true" aria-label="Stock Car Career">
        <header><h1>Stock Car Career</h1><button @click="open = false">Close</button></header>
        <p v-if="message" role="status">{{ message }}</p>
        <div v-if="board" class="career-columns">
          <section>
            <h2>Race calendar</h2>
            <ol>
              <li v-for="(event, i) in board.rounds" :key="event.track" :class="{ next: board.round === i + 1 }">
                <strong>{{ event.track }}</strong>
                <span>{{ event.laps }} laps <template v-if="event.result"> / {{ event.result.place ? 'P' + event.result.place : 'DNF' }}</template></span>
              </li>
            </ol>
            <button :disabled="busy || board.busy || board.round > board.rounds.length" @click="act('race')">Go to race day</button>
          </section>
          <section>
            <h2>Training</h2>
            <p>Finish a two-lap solo run to unlock your first sponsor.</p>
            <button :disabled="busy || board.busy || board.round > board.rounds.length" @click="act('training')">Start training</button>
            <h2>Sponsors</h2>
            <p>{{ board.sponsor || (board.sponsorAvailable ? 'Apex Toolworks offer available' : 'Complete training to unlock an offer') }}</p>
            <p v-if="board.sponsor">250 credit bonus for a top-five finish.</p>
            <button v-if="board.sponsorAvailable && !board.sponsor" :disabled="busy || board.busy" @click="act('sign')">Sign sponsor</button>
            <h2>{{ board.credits }} credits</h2>
          </section>
        </div>
        <p v-else-if="busy">Loading career…</p>
      </section>
    </div>
  </Teleport>
</template>

<style scoped>
.career-entry, .career-board button { background:#edbf54; color:#151a20; border:0; border-radius:5px; padding:.65em 1em; font-weight:750; cursor:pointer; }
.career-entry { position:fixed; top:1.4rem; right:1.4rem; z-index:20; }
.career-board button:disabled { opacity:.45; cursor:default; }
.career-backdrop { position:fixed; inset:0; z-index:10000; display:grid; place-items:center; background:#05090edb; }
.career-board { width:min(740px,90vw); max-height:85vh; overflow:auto; padding:1.6rem; color:#f3f6fb; background:#121c2b; border-top:4px solid #edbf54; border-radius:10px; }
.career-board header { display:flex; align-items:center; justify-content:space-between; gap:1em; }
.career-columns { display:grid; grid-template-columns:1.2fr 1fr; gap:1.5rem; }
.career-board h2 { font-size:1.05rem; margin-top:1.25em; }
.career-board li { padding:.6em; margin:.3em 0; border-left:3px solid transparent; }
.career-board li.next { background:#203049; border-left-color:#edbf54; }
.career-board li span { display:block; color:#b6c5d9; }
@media(max-width:600px) { .career-columns { grid-template-columns:1fr; } }
</style>
