<script setup lang="ts" xmlns:v="http://www.w3.org/1999/xhtml">
import * as THREE from "three";
import { OrbitControls } from "three/addons/controls/OrbitControls.js";
import { computed, onMounted, ref, watch } from "vue";

const loader = new THREE.ImageBitmapLoader();
loader.setOptions({ imageOrientation: "flipY" });
const vpElement = ref<HTMLElement | null>(null);
const meshHeight = ref(2.831);
const radius = ref(1.984);
const circumference = computed(
  () => Math.round(100 * radius.value * 2 * Math.PI) / 100,
);
const diameter = computed(() => Math.round(100 * radius.value * 2) / 100);

let cylinder: THREE.Mesh | null = null;

function createFloor() {
  const ground = new THREE.Mesh(
    new THREE.PlaneGeometry(100, 100, 1, 1),
    new THREE.MeshPhongMaterial({ color: 0xa0adaf, shininess: 150 }),
  );

  ground.rotation.x = -Math.PI / 2; // rotates X/Y to X/Z
  ground.receiveShadow = true;
  ground.position.y = -2;
  return ground;
}

function createJar() {
  const geometry = new THREE.CylinderGeometry(
    radius.value,
    radius.value,
    meshHeight.value,
  );
  const material = new THREE.MeshBasicMaterial({ color: 0x0000ff });
  const c = new THREE.Mesh(geometry, [
    material,
    new THREE.MeshBasicMaterial({ color: 0xff0000 }),
    new THREE.MeshBasicMaterial({ color: 0x00ff00 }),
  ]);
  return c;
}

onMounted(() => {
  if (vpElement.value) {
    const width = vpElement.value.clientWidth;
    const height = vpElement.value.clientHeight;
    const scene = new THREE.Scene();
    const camera = new THREE.PerspectiveCamera(75, width / height, 0.1, 1000);

    const renderer = new THREE.WebGLRenderer({ antialias: true });
    renderer.setPixelRatio(window.devicePixelRatio * 1.5);
    renderer.setSize(width, height);

    new OrbitControls(camera, renderer.domElement);
    const floor = createFloor();

    scene.add(floor);
    cylinder = createJar();
    cylinder.position.y = -2 + meshHeight.value / 2;
    scene.add(cylinder);

    scene.add(new THREE.AmbientLight(0xcccccc));

    const spotLight = new THREE.SpotLight(0xffffff, 60);
    spotLight.angle = Math.PI / 5;
    spotLight.penumbra = 0.2;
    spotLight.position.set(2, 3, 3);
    spotLight.castShadow = true;
    spotLight.shadow.camera.near = 3;
    spotLight.shadow.camera.far = 10;
    spotLight.shadow.mapSize.width = 1024;
    spotLight.shadow.mapSize.height = 1024;
    scene.add(spotLight);

    const dirLight = new THREE.DirectionalLight(0x55505a, 3);
    dirLight.position.set(0, 3, 0);
    dirLight.castShadow = true;
    dirLight.shadow.camera.near = 1;
    dirLight.shadow.camera.far = 10;

    dirLight.shadow.camera.right = 1;
    dirLight.shadow.camera.left = -1;
    dirLight.shadow.camera.top = 1;
    dirLight.shadow.camera.bottom = -1;

    dirLight.shadow.mapSize.width = 1024;
    dirLight.shadow.mapSize.height = 1024;
    scene.add(dirLight);
    renderer.shadowMap.enabled = true;
    camera.position.z = 5;
    vpElement.value.appendChild(renderer.domElement);

    function animate() {
      renderer.render(scene, camera);
    }

    renderer.setAnimationLoop(animate);
  }
});

watch([meshHeight, radius], () => {
  if (cylinder) {
    cylinder.geometry = new THREE.CylinderGeometry(
      radius.value,
      radius.value,
      meshHeight.value,
    );
    cylinder.position.y = -2 + meshHeight.value / 2;
  }
});

const updateRadius = (event: Event) => {
  const target = event.target as HTMLInputElement;
  radius.value = parseFloat(target.value) / (2 * Math.PI);
};

const updateDiameter = (event: Event) => {
  const target = event.target as HTMLInputElement;
  radius.value = parseFloat(target.value) / 2;
};

const updateFile = (event: Event) => {
  const target = event.target as HTMLInputElement;
  const file = target.files?.[0];
  if (file) {
    const url = URL.createObjectURL(file);
    loader.load(url, function (imageBitmap) {
      const texture = new THREE.CanvasTexture(imageBitmap);
      const material = new THREE.MeshBasicMaterial({ map: texture });
      if (cylinder) {
        cylinder.material = [
          material,
          new THREE.MeshBasicMaterial({ color: 0xff0000 }),
          new THREE.MeshBasicMaterial({ color: 0x00ff00 }),
        ];
      }
    });
  }
};
</script>

<template>
  <div class="flex flex-col h-dvh">
    <div ref="vpElement" class="grow"></div>
    <div class="flex gap-4 p-8 items-center">
      <div class="flex gap-2 items-center">
        <label class="font-bold">Height:</label>
        <input v-model="meshHeight" type="number" step=".001" max="6" min="1" />
      </div>
      <div class="flex gap-2 items-center">
        <label class="font-bold">Radius</label>
        <input v-model="radius" type="number" step=".001" max="6" min="1" />
      </div>
      <div class="flex gap-2 items-center">
        <label class="font-bold">Diameter</label>
        <input
          :value="diameter"
          v-on:change="updateDiameter"
          type="number"
          step=".001"
          max="12"
          min="1"
        />
      </div>
      <div class="flex gap-2 items-center">
        <div class="flex flex-col">
          <label class="font-bold">Dieline Width</label>
          <em>(This assumes that the label fully wraps the bottle)</em>
        </div>
        <input
          type="number"
          :value="circumference"
          v-on:change="updateRadius"
          step=".001"
          max="30"
          min="1"
        />
      </div>
      <div class="flex gap-2 items-center">
        <label class="font-bold">File</label>
        <input type="file" v-on:change="updateFile" />
      </div>
    </div>
  </div>
</template>
