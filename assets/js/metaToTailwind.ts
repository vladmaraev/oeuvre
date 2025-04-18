  const base = document.getElementById("speechstate")!.className + " "

export const metaToTailwind = (meta: string | undefined) => {
  switch (meta) {
    case "ready":
      return (
        base +
        `after:content-['Click_to_start!']
        hover:after:content-['Start?_👆']
        hover:bg-green-50 
        `
      );
    case "speaking":
      return (
        base +
        `after:content-['Speaking...']
        hover:after:content-['Pause?_👆']
        hover:bg-green-50
        animate-speaking`
      );
    case "recognising":
      return (
        base +
        `after:content-['Listening...']
        hover:after:content-['Pause?_👆']
        hover:bg-green-50
        animate-recognising`
      );
    case "speaking-paused":
      return (
        base +
        `after:content-['Click_to_continue!']
        hover:after:content-['Continue?_👆']
        hover:bg-green-50
        `
      );
    case "recognising-paused":
      return (
        base +
        `after:content-['Click_to_continue!']
        hover:after:content-['Continue?_👆']
        hover:bg-green-50
        `
      );
    case "prepare":
      return base + `after:content-['Please_wait...']`;
    case "expired":
      return base + `after:content-['Please_submit_the_survey!']`;
    default:
      return base + `after:content-['...']`;
  }
};
