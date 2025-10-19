import { type FC } from "react";

interface ButtonProps {
  count: number;
  onChangeCount: (count: number) => void;
}

export const Button: FC<ButtonProps> = (props) => {
  const { count, onChangeCount } = props;

  return (
    <button onClick={() => onChangeCount(count + 1)}>
      <span className="my-component-class">Vite (</span>
      {count}
      <span className="text-[#ff00ff]">) React</span>
    </button>
  );
};
