<!DOCTYPE html>
<html>
<head>
<style>
.container {
  max-width: 900px;
  margin: auto;
  font-family: Arial, sans-serif;
}

.about {
  text-align: center;
  margin-bottom: 30px;
}

.columns {
  display: flex;
  gap: 40px;
}

.left, .right {
  flex: 1;
}

h2 {
  border-bottom: 1px solid #ccc;
  padding-bottom: 5px;
}
</style>
</head>

<body>

<div class="container">

  <!-- About Me (top) -->
  <div class="about">
    <h1>About Me</h1>
    <p>
      I completed my PhD in Cognitive Psychology at RWTH Aachen University...
    </p>
  </div>

  <!-- Two columns -->
  <div class="columns">

    <!-- Left column -->
    <div class="left">
      <h2>Research Interests</h2>
      <ul>
        <li>Bilingual language control</li>
        <li>Language prediction and processing</li>
        <li>Neurocognitive mechanisms of language switching</li>
      </ul>
    </div>

    <!-- Right column -->
    <div class="right">
      <h2>Skills</h2>
      <ul>
        <li>tDCS experimental design</li>
        <li>EEG/behavioral data analysis</li>
        <li>R / Python / MATLAB</li>
        <li>Statistical modeling</li>
      </ul>
    </div>

  </div>

</div>

</body>
</html>
